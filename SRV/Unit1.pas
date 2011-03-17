unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ScktComp, ExtCtrls;

type
  TUserData = class
  public
    Host:String;
    Socket:Integer;
    Username: String;
    BePrivate: Boolean;
  end;
  TForm1 = class(TForm)
    output: TMemo;
    UserRefresh: TTimer;
    input: TEdit;
    userlist: TListBox;
    btn_kick: TButton;
    btn_info: TButton;
    btn_priv_on: TButton;
    btn_priv_off: TButton;
    btn_privmsg: TButton;
    function GetSelected() : String;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TCPServerRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure TCPServerConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure TCPServerDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure TCPServerError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure broadcast(MSG: String);
    procedure UserRefreshTimer(Sender: TObject);
    procedure inputKeyPress(Sender: TObject; var Key: Char);
    procedure btn_kickClick(Sender: TObject);
    procedure btn_infoClick(Sender: TObject);
    procedure btn_priv_onClick(Sender: TObject);
    procedure btn_priv_offClick(Sender: TObject);
    procedure btn_privmsgClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  TCPServer: TServerSocket;
  Clients: TList;
implementation

{$R *.dfm}


procedure TForm1.broadcast(MSG: String);
var
  n: Integer; //loop-counter
begin
  for n := 0 to clients.count - 1 do                 //Simply go through every user and send him the data...
    TCPServer.Socket.Connections[n].SendText(MSG);
end;

function TForm1.GetSelected() : String;              //Get the username selected
var
  n: Integer;
begin
  for n := 0 to userlist.Items.Count -1 do begin
    if userlist.Selected[n] then begin
      result := userlist.Items.Strings[n];
      exit;
    end
  end;
  result := #129
end;

function GetUserList() : String;                     //Make the userlist ready for the client (USER1#129USER2...)
var
  n: Integer;  //loop-counter
begin
  for n := 0 to clients.Count - 1 do
    result := result + #129 + TUserData(clients[n]).Username;   // #129 is not used
end;

function GetMessage(MSG: String) : String;           //get the message without code... like in the client...
var
  n: Integer;        //loop-counter
  return: String;   //Return value
begin
  for n := 5 to length(MSG) do
    return := return + MSG[n];
  result := return;
end;


//The next block of functions will be self-explaining...


function GetIDbyHost(Host: String) : Integer;
var
  n: Integer; // loop-counter
begin
  for n := 0 to Clients.Count - 1 do begin
    if TUserData(Clients[n]).Host = Host then begin
      result := n;
      exit;
    end;
  end;
  result := -1;
end;

function GetIDbyHandle(Handle: Integer) : Integer;
var
  n: Integer; // loop-counter
begin
  for n := 0 to Clients.Count - 1 do begin
    if TUserData(Clients[n]).Socket = Handle then begin
      result := n;
      exit;
    end;
  end;
  result := -1;
end;

function GetIDbyUser(User: String) : Integer;
var
  n: Integer; // loop-counter
begin
  for n := 0 to Clients.Count - 1 do begin
    if TUserData(Clients[n]).Username = User then begin
      result := n;
      exit;
    end;
  end;
  result := -1;
end;

function GetUserbyHandle(Handle: Integer) : String;
var
  n: Integer; // loop-counter
begin
  for n := 0 to Clients.Count - 1 do begin
    if TUserData(Clients[n]).Socket = Handle then begin
      result := TUserData(Clients[n]).Username;
      exit;
    end;
  end;
  result := 'UnidentifiedUser';
end;


//Read client comments for understanding this... Very easy ;)
procedure TForm1.FormCreate(Sender: TObject);
begin
  output.Text := '';
  output.Lines.Append('[~~] Initializing TCP server...');
  TCPServer := TServerSocket.Create(Form1);
  TCPServer.Port := 9031;
  output.Lines.Append('[~~] Opening TCP server...');
  TCPServer.Open;
  output.Lines.Append('[++] Server Socket is ready.');
  TCPServer.OnClientRead := TCPServerRead;
  TCPServer.OnClientConnect := TCPServerConnect;
  TCPServer.OnClientDisconnect := TCPServerDisconnect;
  TCPServer.OnClientError := TCPServerError;
  Clients := TList.Create;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  TCPServer.Destroy;                      //As always... our nice style ;)
end;

procedure TForm1.TCPServerRead(Sender: TObject; Socket: TCustomWinSocket);
var
  MSG,tmp,tmp2,tmp3: String;
  code, n: integer;
  Client: TUserData;
begin
  MSG := Socket.ReceiveText;
  //showmessage(MSG);
  tmp := MSG[1] + MSG[2] + MSG[3];
  //showmessage(tmp);
  code := StrToIntDef(tmp,000);
  //output.Lines.Append(inttostr(code));
  case code of
  209:  //UPC Username
    begin
    tmp := GetMessage(MSG);
    output.Lines.Append('[++] Username ' + tmp + ' requested by ' + Socket.RemoteHost + '.');
    output.Refresh;
    for n := 1 to length(MSG) do begin
      if MSG[n] = #129 then begin       //HACKER!!! tried to use a username with #129!!
        output.Lines.Append('[WW] ' + Socket.RemoteAddress + ' tried to assign a username containing char 129.');
        output.Refresh;
        Socket.SendText('305 This attempt was logged.');
        exit;
      end;
    end;
    for n := 0 to Clients.Count - 1 do begin
      if TUserData(Clients[n]).Username = tmp then begin
        Socket.SendText('301 Username taken');
        output.Lines.Append('[ee] Username ' + tmp + ' is taken.');
        output.Refresh;
        exit;
      end;
    end;
    if not (GetIDbyHandle(Socket.Handle) = -1) then begin
      TUserData(Clients[GetIDbyHandle(Socket.Handle)]).Username := tmp;
      output.Lines.Append('[ii] Username successfully assigned.');
      Socket.SendText('202 Success.');
      //Socket.Write(Socket.Handle);
      Socket.Write(GetIDByHandle(Socket.Handle));
      UserRefresh.Enabled := True;
    end else begin
      Socket.SendText('305 This attempt was logged.');
      output.Lines.Append('[WW] ' + Socket.RemoteHost + ' (' + Socket.RemoteAddress + ') was trying to assign a username without initiating SYNC at first. This could be hacking...');
    end;
  end;
  201:  //Server SYN
    begin
    output.Lines.Append('[ii] A client has sent the server synchronisation. (' + Socket.RemoteHost + ')');
    output.Refresh;
    output.Lines.Append('[~~] Giving ' + Socket.RemoteHost + ' the INIT...');
    output.Refresh;
    Client:=TUserData.Create;
    Client.Host:=Socket.RemoteAddress;
    Client.Socket:=Socket.Handle;
    Client.Username:=Socket.RemoteAddress + inttostr(Socket.Handle);
    Client.BePrivate:=False;
    Clients.Add(Client);
    output.Lines.Append('[~~] Asking ' + Socket.RemoteHost + ' for username...');
    output.Refresh;
    Socket.SendText('102 Please give me your username');
    end;
  203:   //Upcoming MSG
    begin
      if not (GetMessage(MSG) = '') then begin
        broadcast('203 ' + GetUserByHandle(Socket.Handle) + #129 + GetMessage(MSG));
        if not TUserdata(Clients[GetIDByHandle(Socket.handle)]).BePrivate then
          output.Lines.Append('<' + GetUserByHandle(Socket.Handle) + '> ' + GetMessage(MSG));
        output.Refresh;
      end;
    end;
  210:   //Upcoming PrivMSG
    begin
      if not (GetMessage(MSG) = '') then begin
        tmp := GetMessage(MSG);
        for n := 1 to length(tmp) do begin
          if tmp[n] = #129 then begin
            tmp2 := tmp3;
            tmp3 := '';
          end else
            tmp3 := tmp3 + tmp[n];
        end;
        if GetIDByUser(tmp2) = -1 then begin
          TCPServer.Socket.SendText('303 - Unhandled Exception');
          output.Lines.Append('[!!] ' + Socket.RemoteHost + ' tried to contact a not existing user.');
          exit;
        end;
        if not TUserData(Clients[GetIDByHandle(Socket.handle)]).BePrivate then
          output.Lines.Append('<' + GetUserByHandle(Socket.Handle) + '> -> <' + tmp2 + '> ' + tmp3);
        TCPServer.Socket.Connections[GetIDByUser(tmp2)].SendText('210 ' + GetUserByHandle(Socket.Handle) + #129 + tmp3);
      end;
    end;
  103:    //Request UserLST
      Socket.SendText('205 ' + GetUserList);

  end;
end;

procedure TForm1.TCPServerConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  //showmessage('lol');
  Socket.Accept(Socket.Handle);
  Socket.SendText('208 Connection established.')
end;

procedure TForm1.TCPServerDisconnect(Sender: TObject; Socket: TCustomWinSocket);
var
  tmpl : TList;
  n  : Integer;
begin
  output.lines.Append('[ii] ' + TUserData(clients[GetIDbyHandle(Socket.Handle)]).Host + ' has disconnected.');
  output.Refresh;
  tmpl := TList.Create;
  for n := 0 to Clients.count - 1 do begin
    if not (TUserData(clients[n]).Socket = Socket.Handle) then begin
      tmpl.add(clients[n]);
    end;
  end;
  Clients := tmpl;
  UserRefresh.Enabled := True;  //Sockets need some time to get the correct IDs. We give them 10 ms (+ object latency) which should be more than enough
end;
procedure TForm1.UserRefreshTimer(Sender: TObject);
var
  tmp : String;
  n : Integer;
begin
  tmp := '205 ' + GetUserList;
  broadcast(tmp);
  userlist.Clear;
  for n := 0 to Clients.count - 1 do
    userlist.Items.Append(TUserdata(Clients[n]).Username);
  userlist.Refresh;

  UserRefresh.Enabled := False;
end;

procedure TForm1.inputKeyPress(Sender: TObject; var Key: Char);
begin
if key = #13 then begin
  broadcast('211 ' + input.Text);
  output.Lines.Append('Server: ' + input.Text);
  input.Text := '';
end;
end;

procedure TForm1.btn_kickClick(Sender: TObject);
var
  tmpl : TList;
  n  : Integer;
begin
  if GetSelected = #129 then exit;
  output.Lines.Append('[ii] Kicking ' + GetSelected);
  TCPServer.Socket.Connections[GetIDByUser(GetSelected)].Close;
  //Kind of badly solved... But worx ;)
  tmpl := TList.Create;
  for n := 0 to Clients.count - 1 do begin
    if not (TUserData(clients[n]).Username = GetSelected) then begin
      tmpl.add(clients[n]);
    end;
  end;
  Clients := tmpl;
  UserRefresh.Enabled := True;
end;

procedure TForm1.btn_infoClick(Sender: TObject);
begin
  if GetSelected = #129 then exit;
  showmessage('UID: ' + inttostr(GetIDByUser(GetSelected)) + #13 + #10 + 'Host: ' + TUserData(Clients[GetIDByUser(GetSelected)]).Host  + #13 + #10 + 'Username: ' + TUserData(Clients[GetIDByUser(GetSelected)]).Username);
end;

procedure TForm1.btn_priv_onClick(Sender: TObject);
begin
  if GetSelected = #129 then exit;
  TUserData(Clients[GetIDByUser(GetSelected)]).BePrivate := True;
  output.Lines.Append('Granted ' + GetSelected + ' private rights.');
  output.Refresh;
  TCPServer.Socket.Connections[GetIDByUser(GetSelected)].SendText('211 You are now private.');
end;

procedure TForm1.btn_priv_offClick(Sender: TObject);
begin
  if GetSelected = #129 then exit;
  TUserData(Clients[GetIDByUser(GetSelected)]).BePrivate := False;
  output.Lines.Append('Revoked ' + GetSelected + 's private rights.');
  output.Refresh;
  TCPServer.Socket.Connections[GetIDByUser(GetSelected)].SendText('211 You are NOT private.');
end;

procedure TForm1.btn_privmsgClick(Sender: TObject);
var
  MSG: String;
begin
  if GetSelected = #129 then exit;
  MSG := InputBox('InstantCom2 Server', 'Private Message to ' + GetSelected, '');
  output.lines.Append('[PP] -> <' + GetSelected + '> ' + MSG);
  output.Refresh;
  TCPServer.Socket.Connections[GetIDByUser(GetSelected)].SendText('211 [PRIVATE] ' + MSG);
end;

procedure TForm1.TCPServerError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  output.lines.Append('[ii] ' + TUserData(clients[GetIDbyHandle(Socket.Handle)]).Host + ' jumped out of the window(s).');
  Socket.Close;
  ErrorCode := 0; //Nothing happened, just walk on!
end;
end.
