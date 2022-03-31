object AboutBox: TAboutBox
  Left = 200
  Top = 108
  BorderStyle = bsDialog
  Caption = 'About'
  ClientHeight = 213
  ClientWidth = 298
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 9
    Top = 8
    Width = 281
    Height = 161
    BevelInner = bvRaised
    BevelOuter = bvLowered
    ParentColor = True
    TabOrder = 0
    object ProductName: TLabel
      Left = 16
      Top = 16
      Width = 140
      Height = 13
      Caption = 'Product Name : Tree Browser'
      IsControl = True
    end
    object Label1: TLabel
      Left = 16
      Top = 131
      Width = 149
      Height = 13
      Caption = 'Email : djaballahchr@gmail.com'
    end
    object Label2: TLabel
      Left = 32
      Top = 67
      Width = 225
      Height = 39
      AutoSize = False
      Caption = 
        'An Experimental example to illustrate all the aspects of the ide' +
        'a'#13#10'Greetings yours Djaballah Mustapha Djaballah belkacem'#13#10
      Transparent = True
      WordWrap = True
    end
    object Label3: TLabel
      Left = 16
      Top = 48
      Width = 97
      Height = 13
      Caption = 'Product information :'
      IsControl = True
    end
  end
  object OKButton: TButton
    Left = 111
    Top = 180
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
end
