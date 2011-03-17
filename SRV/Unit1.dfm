object Form1: TForm1
  Left = 435
  Top = 237
  Width = 811
  Height = 434
  Caption = 'ICom2 Server'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object output: TMemo
    Left = 0
    Top = 0
    Width = 601
    Height = 377
    Lines.Strings = (
      'output')
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object input: TEdit
    Left = 0
    Top = 376
    Width = 601
    Height = 21
    TabOrder = 1
    OnKeyPress = inputKeyPress
  end
  object userlist: TListBox
    Left = 600
    Top = 0
    Width = 121
    Height = 369
    ItemHeight = 13
    ScrollWidth = 1
    TabOrder = 2
  end
  object btn_kick: TButton
    Left = 720
    Top = 0
    Width = 75
    Height = 25
    Caption = 'Kick'
    TabOrder = 3
    OnClick = btn_kickClick
  end
  object btn_info: TButton
    Left = 720
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Get Info'
    TabOrder = 4
    OnClick = btn_infoClick
  end
  object btn_priv_on: TButton
    Left = 720
    Top = 48
    Width = 75
    Height = 25
    Caption = 'Private on'
    TabOrder = 5
    OnClick = btn_priv_onClick
  end
  object btn_priv_off: TButton
    Left = 720
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Private off'
    TabOrder = 6
    OnClick = btn_priv_offClick
  end
  object btn_privmsg: TButton
    Left = 720
    Top = 96
    Width = 75
    Height = 25
    Caption = 'Send Message'
    TabOrder = 7
    OnClick = btn_privmsgClick
  end
  object UserRefresh: TTimer
    Interval = 10
    OnTimer = UserRefreshTimer
    Top = 408
  end
end
