// This is part of the Obo Component Library
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// This software is distributed without any warranty.
//
// @author Domenico Mammola (mimmo71@gmail.com - www.mammola.net)

unit mLookupPanelInstantQuery;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  Classes, Controls, ExtCtrls, DB, Buttons,
  StdCtrls,
  mDataProviderInterfaces, mQuickReadOnlyVirtualDataSet,
  mVirtualDataSet, mLookupWindowEvents,
  DBGrids;

resourcestring
  rsSearchButtonCaption = 'Search';

type

  { TmLookupPanelInstantQuery }

  TmLookupPanelInstantQuery = class (TCustomPanel)
  strict private
    FGrid : TDBGrid;
    FDatasource : TDatasource;
    FTopPanel : TPanel;
    FSearchBtn : TButton;
    FEditText: TEdit;
    FDisplayFieldNames : TStringList;
    FKeyFieldName : String;
    FOnSelectAValue : TOnSelectAValue;

    FDatasetProvider: TReadOnlyVirtualDatasetProvider;
    FVirtualDataset : TmVirtualDataset;
    FInstantQueryManager : IVDInstantQueryManager;

    procedure OnClickSearch(aSender : TObject);
    procedure OnDoubleClickGrid(Sender: TObject);
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init(const aInstantQueryManager : IVDInstantQueryManager); overload;
    procedure Init(const aInstantQueryManager : IVDInstantQueryManager; const aFieldNames : TStringList; const aKeyFieldName : string; const aDisplayFieldNames : TStringList); overload;
    procedure SetFocusOnFilter;
    procedure GetSelectedValues (out aKeyValue: variant; out aDisplayLabel: string);

    property OnSelectAValue : TOnSelectAValue read FOnSelectAValue write FOnSelectAValue;
  end;



implementation

uses
  Variants, Forms;

{ TmLookupPanelInstantQuery }

procedure TmLookupPanelInstantQuery.OnClickSearch(aSender: TObject);
var
  OldCursor : TCursor;
begin
  if Assigned(FInstantQueryManager) then
  begin
    OldCursor := Screen.Cursor;
    try
      Screen.Cursor := crHourGlass;
      FInstantQueryManager.FilterDataProvider(FEditText.Text);
      FVirtualDataset.Refresh;
      FGrid.AutoAdjustColumns;
    finally
      Screen.Cursor := OldCursor;
    end;
  end;
end;

procedure TmLookupPanelInstantQuery.OnDoubleClickGrid(Sender: TObject);
var
  tmpDisplayLabel: string;
  tmpKeyValue: variant;
begin
  if (FGrid.SelectedRows.Count = 1) and (Assigned(FOnSelectAValue)) then
  begin
    Self.GetSelectedValues(tmpKeyValue, tmpDisplayLabel);
    FOnSelectAValue(tmpKeyValue, tmpDisplayLabel);
  end;
end;

constructor TmLookupPanelInstantQuery.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);

  FDatasource := TDataSource.Create(Self);
  FVirtualDataset := TmVirtualDataset.Create(Self);
  FInstantQueryManager := nil;
  FDisplayFieldNames := TStringList.Create;
  FKeyFieldName:= '';

  FDatasetProvider:= TReadOnlyVirtualDatasetProvider.Create;

  FTopPanel := TPanel.Create(Self);
  FTopPanel.Parent := Self;
  FTopPanel.Align:= alTop;
  FTopPanel.BevelInner:= bvNone;
  FTopPanel.BevelOuter:= bvNone;
  FTopPanel.Caption := '';
  FTopPanel.Height:= 20;

  FGrid := TDBGrid.Create(Self);
  FGrid.Parent := Self;
  FGrid.Align:= alClient;
  FGrid.DataSource := FDatasource;
  FGrid.Flat := True;
  FGrid.Options := [dgTitles, dgIndicator, dgColumnResize, dgColumnMove, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgAutoSizeColumns, dgDisableDelete, dgDisableInsert, dgMultiselect];
  FGrid.OnDblClick:=OnDoubleClickGrid;
  FDatasource.DataSet := FVirtualDataset;
  FVirtualDataset.DatasetDataProvider := FDatasetProvider;

  FSearchBtn := TButton.Create(FTopPanel);
  FSearchBtn.Parent := FTopPanel;
  FSearchBtn.Caption:= rsSearchButtonCaption;
  FSearchBtn.Align:= alRight;
  FSearchBtn.OnClick:= Self.OnClickSearch;
  FSearchBtn.Default:= true;

  FEditText:= TEdit.Create(FTopPanel);
  FEditText.Parent := FTopPanel;
  FEditText.Align:= alClient;
end;

destructor TmLookupPanelInstantQuery.Destroy;
begin
  FVirtualDataset.Active:= false;
  FDatasetProvider.Free;
  FDisplayFieldNames.Free;
  inherited Destroy;
end;

procedure TmLookupPanelInstantQuery.Init(const aInstantQueryManager: IVDInstantQueryManager);
begin
  Self.Init(aInstantQueryManager, nil, '', nil);
end;

procedure TmLookupPanelInstantQuery.Init(const aInstantQueryManager: IVDInstantQueryManager; const aFieldNames: TStringList; const aKeyFieldName: string; const aDisplayFieldNames: TStringList);
var
  fields : TStringList;
  i : integer;
begin
  FInstantQueryManager := aInstantQueryManager;
  FInstantQueryManager.Clear;
  FGrid.DataSource.DataSet.DisableControls;
  try
    FDatasetProvider.Init(FInstantQueryManager.GetDataProvider);
    FInstantQueryManager.GetDataProvider.FillVirtualFieldDefs(FDatasetProvider.VirtualFieldDefs, '');
    FVirtualDataset.Active:= true;
    FVirtualDataset.Refresh;
    fields := TStringList.Create;
    try
      if aFieldNames <> nil then
        fields.AddStrings(aFieldNames)
      else
        FInstantQueryManager.GetDataProvider.GetMinimumFields(fields);
      for i := 0 to FVirtualDataset.Fields.Count - 1 do
      begin
        if fields.IndexOf(FVirtualDataset.Fields[i].FieldName) < 0 then
          FVirtualDataset.Fields[i].Visible:= false;
      end;
    finally
      fields.Free;
    end;
    FDisplayFieldNames.Clear;
    if aDisplayFieldNames <> nil then
      FDisplayFieldNames.AddStrings(aDisplayFieldNames)
    else
      FInstantQueryManager.GetDataProvider.GetMinimumFields(FDisplayFieldNames);

    FKeyFieldName:= aKeyFieldName;
    if FKeyFieldName = '' then
      FKeyFieldName:= aInstantQueryManager.GetDataProvider.GetKeyFieldName;
  finally
    FGrid.DataSource.DataSet.EnableControls;
  end;
end;

procedure TmLookupPanelInstantQuery.SetFocusOnFilter;
begin
  FEditText.SetFocus;
end;

procedure TmLookupPanelInstantQuery.GetSelectedValues(out aKeyValue: variant; out aDisplayLabel: string);
var
  value : Variant;
begin
  aKeyValue := null;
  aDisplayLabel:= '';
  if FGrid.SelectedRows.Count = 1 then
  begin
    aKeyValue := FVirtualDataset.FieldByName(FKeyFieldName).Value;
    value := FVirtualDataset.FieldByName(FInstantQueryManager.GetDataProvider.GetKeyFieldName).Value;
    aDisplayLabel:= ConcatenateFieldValues(FInstantQueryManager.GetDataProvider.FindDatumByStringKey(VarToStr(value)), FDisplayFieldNames);
  end;
end;

end.
