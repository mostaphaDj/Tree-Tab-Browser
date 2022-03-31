program TreeBrowser;

uses
  Forms,
  About in 'About.pas' {AboutBox},
  Unit1 in 'Unit1.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Tree Browser';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
