unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  mTimeruler;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    timeruler : TmTimeruler;
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  dateutils,
  mTimerulerScales, mTimerulerTimelines;

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  tmp : TmTimeline;
begin
  timeruler := TmTimeruler.Create(Self);
  timeruler.Parent := Self;
  timeruler.Align := alTop;
  timeruler.Font.Name:= 'Calibri';
  timeruler.Font.Size:= 8;
  timeruler.MinDate:= EncodeDate(YearOf(Now),1,1);;
  timeruler.MaxDate:= EncodeDate(YearOf(Now),12,31);;

  tmp := timeruler.AddTimeline(TmScaleMonth);
  tmp.Scale.DisplayFormat:= '<UPPERCASE>MMM yyyy';
  tmp.Color:= clSkyBlue;
  tmp.Flex:=1;
  tmp := timeruler.AddTimeline(TmScaleWeek);
  tmp.Scale.DisplayFormat:= 'week <xx>';
  tmp.Color:= clSkyBlue;
  tmp.Flex:=1;
  tmp := timeruler.AddTimeline(TmScaleDayNotSaturdaySunday);
  tmp.Scale.DisplayFormat:='dd';
  tmp.Color:= clSkyBlue;
  tmp.Flex:=2;
  timeruler.Rebuild;
  timeruler.CurrentDate := EncodeDate(YearOf(Now),1,16);
  timeruler.Height:= 50;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  timeruler.CurrentDate:= EncodeDate(YearOf(Now), 2, 1);
end;

end.

