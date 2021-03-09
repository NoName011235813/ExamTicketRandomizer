unit uNewTickets;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TfNewTickets }

  TfNewTickets = class(TForm)
    eNum: TEdit;
    Label1: TLabel;
    bClose: TPanel;
    bBack: TPanel;
    bOk: TPanel;
    sdTicket: TSaveDialog;
    procedure bBackClick(Sender: TObject);
    procedure bCloseClick(Sender: TObject);
    procedure bOkClick(Sender: TObject);
    procedure eNumKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure PanelEnter(Sender: TPanel);

    procedure PanelExit(Sender: TPanel);

    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);


  private

  public

  end;

var
  fNewTickets: TfNewTickets;

implementation
uses main; // основная форма
{$R *.lfm}

{ TfNewTickets }

{
  $00635A56 - light gray
  $003F3936 - gray
}


//переменные для иммитации рамки(перемещения)
var topClicked:boolean;// верхняя область была нажата
    mX,mY:integer;//координаты мыши

//обеспечение ввода только цифрами
procedure TfNewTickets.eNumKeyPress(Sender: TObject; var Key: char);
begin
  case key of
    '0'..'9', chr(8):;
    else key:=chr(0);
  end
end;

//показать или нет кнопку назад
procedure TfNewTickets.FormShow(Sender: TObject);
begin
 if fMain.validFile(FILENAME) then
    bBack.Visible:=true
 else
    bBack.Visible:=false
end;

//кнопка подтверждения
procedure TfNewTickets.bOkClick(Sender: TObject);
var f:ticketFile;
    ticketsData:ticketDataType;
    i:byte;
    group:string;
    temp:integer;
begin
  if tryStrToInt(eNum.Text, temp) then begin
    if (temp <= MAXTICKETNUM) and (temp > 0) then begin

      //если файл уже существует то предлагаем его сохранить
      if fMain.validFile(FILENAME) then
        if messageDlg('Потверждение', 'Хотите ли вы сохранить открытый ряд билетов?',
                      mtConfirmation, [mbOK, mbCancel], '') = mrOK
        //если пользователь дал добро
        then
          fMain.bSaveClick(fMain.bSave);


      assignFile(f, FILENAME);

      //запись кол-ва билетов и сободных билетов
      ticketsData.ticketNum:=temp;
      ticketsData.freeTicketNum:=temp;

      //запись билетов
      for i:=1 to temp do
        ticketsData.tickets[i]:=i;

      //запись данных в файл
      rewrite(f);

      write(f, ticketsData);

      closeFile(f);

      fNewTickets.close
    end else
      messageDlg('Ошибка', 'Вы ввели слишком большое значение или 0', mtError, [mbOK], '')
  end else
    messageDlg('Ошибка', 'Вы ввели неправильное значие, введите пожалуйста целое ненулевое число', mtError, [mbOK], '')
end;

//кнопка назад
procedure TfNewTickets.bBackClick(Sender: TObject);
begin
  if fMain.validFile(FILENAME) then
    fNewTickets.close
  else if not fileExists(FILENAME) then
    messageDlg('Ошибка', 'Вы не можете вернуться, так как файл был удален', mtError, [mbOK], '')
end;

//кнопка выхода
procedure TfNewTickets.bCloseClick(Sender: TObject);
begin
  if fMain.validFile(FILENAME) then begin
    fNewTickets.close
  end else begin
    if fileExists(FILENAME) then
      deleteFile(FILENAME);
    fMain.close
  end
end;

//указываем что пользователь хочет переместить форму
procedure TfNewTickets.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (y<35) and (button=mbLeft) then begin
    mX:=x;
    mY:=y;

    topClicked:=true
  end
end;

//перемещение формы
procedure TfNewTickets.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if topClicked then begin
    fNewTickets.Left:=fNewTickets.Left+(x-mX);
    fNewTickets.Top:=fNewTickets.Top+(y-mY)
  end
end;

//указываем что пользователь перестал перемещать форму
procedure TfNewTickets.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  topClicked:=false
end;

//вход мыши в пределы панели
procedure TfNewTickets.PanelEnter(Sender: TPanel);
begin
  Sender.Color:=$00635A56
end;

//выход мыши в пределы панели
procedure TfNewTickets.PanelExit(Sender: TPanel);
begin
  Sender.Color:=$003F3936
end;


end.

