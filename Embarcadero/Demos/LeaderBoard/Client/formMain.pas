unit formMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Fmx.Bind.GenData, Data.Bind.GenData, System.Rtti, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.EngExt, Fmx.Bind.DBEngExt, FMX.Layouts, FMX.Edit,
  Data.Bind.Components, Data.Bind.ObjectScope, IPPeerClient, IPPeerServer,
  System.Tether.Manager, System.Tether.AppProfile, FMX.ListView.Types,
  FMX.ListView, unitGame;

type
  TfrmMain = class(TForm)
    BindingsList1: TBindingsList;
    gbPlayer: TGroupBox;
    EditName: TEdit;
    LabelName: TLabel;
    EditScore: TEdit;
    LabelScore: TLabel;
    Layout1: TLayout;
    gbScoreboard: TGroupBox;
    sbGuess: TSpinBox;
    btnGuess: TButton;
    Label1: TLabel;
    Layout2: TLayout;
    ListView1: TListView;
    LinkListControlToField1: TLinkListControlToField;
    btnConnect: TButton;
    LinkControlToField1: TLinkControlToField;
    LinkControlToField2: TLinkControlToField;
    Label2: TLabel;
    LinkPropertyToFieldText: TLinkPropertyToField;
    lblResult: TLabel;
    procedure btnConnectClick(Sender: TObject);
    procedure btnGuessClick(Sender: TObject);
  private
    { Private declarations }
    Game : TGuessingGame;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

uses dmMain, unitGamePlayer;

procedure TfrmMain.btnConnectClick(Sender: TObject);
begin
  dmMain.dataMain.ConnectToScoreboard;
end;

procedure TfrmMain.btnGuessClick(Sender: TObject);
var
  R: TGuessResult;
begin
  if Game = nil then begin
    Game := TGuessingGame.Create(TGamePlayer(dmMain.dataMain.pbsPlayer.InternalAdapter.Current));
  end;

  R := Game.HaveAGuess(Trunc(sbGuess.Value));
  case R of
    Correct: begin
               lblResult.Text := 'Congratulations - you guessing in '+Game.Guesses.ToString+' guesses';
               Game.Player.Score := Game.Guesses;
               dataMain.pbsPlayer.ApplyUpdates;
               dataMain.SendScore;
               Game.Reset;
             end;
    ToHigh : lblResult.Text := 'To High';
    ToLow  : lblResult.Text := 'To Low';
  end;
end;

end.
