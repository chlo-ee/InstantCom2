
unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Unit1, StdCtrls;

type
  TSplash = class(TForm)
    Image1: TImage;
    Timer1: TTimer;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Splash: TSplash;
  Form1: TForm1;
implementation

{$R *.dfm}
{$R resources.RES}

procedure TSplash.FormCreate(Sender: TObject);
var BG : TBitmap;
begin
  Label1.Caption := Application.ExeName;          //We are cool and therefor show the exe in the splash (why not?)
  try                                             //We need to do this first
    BG := TBitmap.Create;                         //BG will be our image
    BG.Handle := LoadBitmap(hInstance, 'WALL');   //load the bitmap "WALL" out of RESOURCES.res
    Image1.Width := BG.Width;                     //Was to lazy to hardcode...
    Image1.Height := BG.Height;                   //Same
    Image1.Canvas.Draw(0,0,BG);                   //Draw the bitmap!
  finally
    BG.free; //FREE KEVIN! or the bg...
  end;
end;

procedure TSplash.Timer1Timer(Sender: TObject);
begin
  Application.CreateForm(TForm1,Form1); //Create the MainForm
  Form1.Show;                           //Show it
  Splash.Destroy;                       //SUICIDE
end;

end.
