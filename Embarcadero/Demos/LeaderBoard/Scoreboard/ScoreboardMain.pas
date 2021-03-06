unit ScoreboardMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Data.Bind.GenData, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Data.Bind.Components,
  Data.Bind.ObjectScope, System.Rtti, Data.Bind.EngExt, Fmx.Bind.DBEngExt,
  Fmx.Bind.Grid, System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.Grid,
  FMX.Layouts, FMX.Grid, Data.Bind.DBScope, IPPeerClient, IPPeerServer,
  System.Tether.Manager, System.Tether.AppProfile, FireDAC.Stan.StorageXML,
  System.Actions, FMX.ActnList, Data.Bind.Controls, Fmx.Bind.Navigator, FMX.Memo;

type
  TForm6 = class(TForm)
    tableScores: TFDMemTable;
    tableScoresScore: TIntegerField;
    tableScoresName: TStringField;
    BindSourceDB1: TBindSourceDB;
    Grid1: TGrid;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    TetheringManager1: TTetheringManager;
    TetheringAppProfile1: TTetheringAppProfile;
    FDStanStorageXMLLink1: TFDStanStorageXMLLink;
    ActionList1: TActionList;
    actGetScores: TAction;
    NavigatorBindSourceDB1: TBindNavigator;
    Memo1: TMemo;
    Splitter1: TSplitter;
    procedure TetheringAppProfile1ResourceReceived(const Sender: TObject;
      const AResource: TRemoteResource);
    procedure tableScoresAfterPost(DataSet: TDataSet);
    procedure FormCreate(Sender: TObject);
    procedure actGetScoresExecute(Sender: TObject);
  private
    procedure UpdateScoreObjects;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form6: TForm6;

implementation

{$R *.fmx}

uses unitGamePlayer, Rest.JSON;

procedure TForm6.actGetScoresExecute(Sender: TObject);
begin
  Memo1.Lines.Add('actGetScores.Execute');
  UpdateScoreObjects;
end;

procedure TForm6.FormCreate(Sender: TObject);
begin
  Randomize;
  try
    tableScores.LoadFromFile('Score.xml');
  except
    tableScores.CreateDataSet;
  end;
end;

procedure TForm6.UpdateScoreObjects;
var
  clone: TFDMemTable;
  GP: TGamePlayer;
  SL : TStringList;
begin
  Memo1.Lines.Add('Updating Score Objects Data');
  clone := TFDMemTable.Create(Self);
  try
    clone.CloneCursor(tableScores);
    clone.First;
    SL := TStringList.Create;
    try
      while not Clone.Eof do
      begin
        GP := TGamePlayer.Create(clone.FieldByName('Name').AsString);
        try
          GP.Score := clone.FieldByName('Score').AsInteger;
          SL.Add(TJson.ObjectToJsonString(GP));
        finally
          GP.Free;
        end;
        Clone.Next;
        if SL.Count >= 5 then // Passes top 5 scores
          Break;
      end;
      SL.Delimiter := Data_Delimiter;
      TetheringAppProfile1.Resources.FindByName('Scoreboard').Value := SL.DelimitedText;
      Memo1.Lines.Add(SL.DelimitedText);
    finally
      SL.Free;
    end;
  finally
    clone.Free;
  end;
end;

procedure TForm6.tableScoresAfterPost(DataSet: TDataSet);
begin
  tableScores.SaveToFile('Score.xml');
  UpdateScoreObjects;
end;

procedure TForm6.TetheringAppProfile1ResourceReceived(const Sender: TObject;
  const AResource: TRemoteResource);
var
  Player : TGamePlayer;
begin
  if AResource.ResType = TRemoteResourceType.Data then begin
    // Take the string value, convert to the object and add to the dataset.
    Player := TJson.JsonToObject<TGamePlayer>(AResource.Value.AsString);

    if tableScores.Locate('Name',Player.Name,[loCaseInsensitive]) then
      tableScores.Edit
    else begin
      tableScores.Insert;
      tableScoresName.AsString := Player.Name;
    end;
    tableScoresScore.AsInteger := Player.Score;
    tableScores.Post;
  end;
end;

end.
