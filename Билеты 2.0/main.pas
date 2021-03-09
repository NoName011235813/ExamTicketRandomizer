unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, Grids, Types;

type

  { TfMain }

  TfMain = class(TForm)
    bClose: TPanel;
    bMinimize: TPanel;
    bTabGenerate: TPanel;
    bGenerate: TPanel;
    bNewTickets: TPanel;
    bFreeTicket: TPanel;
    bOptions: TPanel;
    bSave: TPanel;
    bLoad: TPanel;
    bTakenTicket: TPanel;
    bTabList: TPanel;
    Label1: TLabel;
    lTitle: TLabel;
    lTicket: TLabel;
    odTicket: TOpenDialog;
    pBottom: TPanel;
    pTop: TPanel;
    pBack1: TPanel;
    pBack2: TPanel;
    pBack3: TPanel;
    pc: TPageControl;
    sdTicket: TSaveDialog;
    tabOptions: TTabSheet;
    ticketsGrid: TStringGrid;
    tabGenerate: TTabSheet;
    tabList: TTabSheet;
    procedure bCloseClick(Sender: TObject);
    procedure bFreeTicketClick(Sender: TObject);
    procedure bGenerateClick(Sender: TObject);
    procedure bLoadClick(Sender: TObject);
    procedure bMinimizeClick(Sender: TObject);
    procedure bNewTicketsClick(Sender: TObject);
    procedure bSaveClick(Sender: TObject);
    procedure bTakenTicketClick(Sender: TObject);
    procedure tabClick(Sender: TPanel);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ticketsGridDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);

    function validFile(str:string):boolean;

    procedure PanelEnter(Sender: TPanel);
    procedure PanelExit(Sender: TPanel);
  private

  public

  end;

var
  fMain: TfMain;

const MAXTICKETNUM = 200; //максимальное кол-во билетов
      FILENAME = 'tickets.tsk'; //имя файла по умолчанию

type ticketArray = array[1..MAXTICKETNUM] of byte; //массив билетов

     //тип файла хранения данных
     ticketDataType = record
       ticketNum:byte; //общее кол-во билетов
       freeTicketNum:byte; //кол-во доступных билетов
       tickets:ticketArray; //доступные билеты
     end;

     ticketFile = file of ticketDataType; //тип файла с билетами


implementation
uses uNewTickets; // форма для ввода нового кол-ва билетов
{$R *.lfm}


{ TfMain }

{
  $00252220 - black
  $00635A56 - light gray
  $003F3936 - gray
}


//Инструменты
//функция считываение записи из файла
function getFileData(var f:ticketFile):ticketDataType;
begin
  reset(f);

  read(f, getFileData);

  closeFile(f)
end;

//запись кол-ва доступных билетов и массив доступных билетов в файл
procedure setFileData(var f:ticketFile; newData:ticketDataType);
begin
  rewrite(f);

  write(f, newData);

  closeFile(f)
end;

//функция проверяющая валидность файла
function TfMain.validFile(str:string):boolean;
var f:ticketFile;
    temp:ticketDataType;
begin
  //проверка на существование файла
  if fileExists(str) then
    try
      //проверка на читаемость файла
      assignFile(f, str);
      reset(f);
      read(f, temp);
      closeFile(f);

      validFile:=true
    except
      closeFile(f);
      validFile:=false
    end
  else
    validFile:=false
end;

//процедура удаления элемента из массива
procedure deleteElement(k,n: byte; var arr:ticketArray);
var i:byte;
begin
  //начиная с k-го элемента смещаем элементы влево
  for i:=k to n-1 do
    arr[i]:=arr[i+1];

  //последний := 0
  arr[n]:=0
end;



//функционал формы
//------------------------------------------------------------------------------
//настройки
procedure TfMain.FormCreate(Sender: TObject);
begin
  ticketsGrid.ColWidths[0]:=95;
  ticketsGrid.ColWidths[1]:=272;

  ticketsGrid.Cells[0, 0]:='Билеты';
  ticketsGrid.Cells[1, 0]:='Статус';

  pc.activePage:=tabGenerate;

  lTitle.caption:='Генерация билета'
end;

//кнопка закрытия
procedure TfMain.bCloseClick(Sender: TObject);
begin
  fMain.close
end;

//отрисовка цветного теста в таблице
procedure TfMain.ticketsGridDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
begin
  {
    lightGreen - $003EDF1C
    red - $001711FF
  }

  if ticketsGrid.Cells[aCol, aRow] = 'Доступен' then begin
    ticketsGrid.canvas.font.color := $003EDF1C;
    ticketsGrid.canvas.textOut(aRect.left+3, aRect.top+3, 'Доступен')
  end else if ticketsGrid.Cells[aCol, aRow] = 'Выдан' then begin
    ticketsGrid.canvas.font.color := $001711FF;
    ticketsGrid.canvas.textOut(aRect.left+3, aRect.top+3, 'Выдан')
  end;
end;

//подсветка кнопок
//вход мыши в пределы панели
procedure TfMain.PanelEnter(Sender: TPanel);
begin
  Sender.Color:=$00635A56
end;

//выход мыши в пределы панели
procedure TfMain.PanelExit(Sender: TPanel);
begin
  Sender.Color:=$003F3936
end;

//свернуть окно
procedure TfMain.bMinimizeClick(Sender: TObject);
begin
  Application.minimize
end;
//------------------------------------------------------------------------------



//перемещение формы
//------------------------------------------------------------------------------

var topClicked : boolean;//произошло нажатие "рамки"
    mX,mY : integer;//координаты мыши

//передеча информации о желании переместить форму
procedure TfMain.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (y<29) and (Button = mbLeft) then begin
    mX:=x;
    mY:=y;

    topClicked:=true
  end
end;

//передача положения мыши
procedure TfMain.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if topClicked then begin
    fMain.Left:=fMain.Left + (x-mX);
    fMain.Top:=fMain.Top + (y-mY)
  end
end;

//отмена перемещения
procedure TfMain.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  topClicked:=false
end;
//------------------------------------------------------------------------------



//Имитация вкладок и обновление списка
procedure TfMain.tabClick(Sender: TPanel);
var f:ticketFile;
    ticketData: ticketDataType;
    i: byte;
    freeTickets: set of 1..MAXTICKETNUM;
begin
  if Sender = bTabGenerate then begin
    pc.activePage:=tabGenerate;
    lTitle.Caption:='Генерация билета'
  end else if Sender = bTabList then begin
    pc.activePage:=tabList;
    lTitle.Caption:='Список билетов';

    //проверка на существование и доступности файла
    if validFile(FILENAME) then begin
      assignFile(f, FILENAME);

      //считывание данных
      ticketData:= getFileData(f)
    end else begin
      messageDlg('Ошибка', 'Файл недоступен, либо удален, либо поврежден, советуем создать новый файл билетов', mtError, [mbOk], '');
      exit
    end;

    //"очистка"
    ticketsGrid.rowCount:=1;

    //заполнение множества доступными билетами
    freeTickets:=[];
    for i:=1 to ticketData.freeTicketNum do
      freeTickets:=freeTickets+[ticketData.tickets[i]];

    //перенос данных в таблицу
    for i:=1 to ticketData.ticketNum do begin
      ticketsGrid.rowCount:= ticketsGrid.rowCount + 1;

      ticketsGrid.Cells[0, ticketsGrid.rowCount - 1]:=intToStr(i);

      //распознование статуса билета
      if i in freeTickets then
        ticketsGrid.Cells[1, ticketsGrid.rowCount - 1]:='Доступен'
      else
        ticketsGrid.Cells[1, ticketsGrid.rowCount - 1]:='Выдан';

    end;

  end else begin
    pc.activePage:=tabOptions;
    lTitle.Caption:='Настройки'
  end
end;



//Вкладка - Новый билет
//------------------------------------------------------------------------------
//кнопка генерировать
procedure TfMain.bGenerateClick(Sender: TObject);
var f : ticketFile;
    ticketData : ticketDataType;
    temp : byte;
begin
  randomize;

  //проверка на существование и доступ к файлу
  if validFile(FILENAME) then begin
    assignFile(f, FILENAME);

    //считывание данных
    ticketData:=getFileData(f)
  end else begin
    messageDlg('Ошибка', 'Файл недоступен, либо удален, либо поврежден, советуем создать новый файл билетов', mtError, [mbOk], '');
    exit
  end;

  //если доступных билетов нет то выход
  if ticketData.freeTicketNum<1 then begin
    messageDlg('Ошибка', 'Все билеты разданы', mtError, [mbOk], '');
    exit
  end;

  //случайное число в зависимости от кол-ва доступных билетов
  temp:=random(ticketData.freeTicketNum)+1;

  //передача билета
  lTicket.Caption:=intToStr(ticketData.tickets[temp]);

  //удаление и вычисление нового количества доступных билетов
  deleteElement(temp, ticketData.freeTicketNum, ticketData.tickets);
  ticketData.freeTicketNum:=ticketData.freeTicketNum-1;

  //запись новых данных
  setFileData(f, ticketData)

end;

//новые билеты
procedure TfMain.bNewTicketsClick(Sender: TObject);
begin
  fNewTickets.ShowModal
end;
//------------------------------------------------------------------------------



//Вкладка - Список билетов
//------------------------------------------------------------------------------
//пометить билет как доступный
procedure TfMain.bFreeTicketClick(Sender: TObject);
var temp, i: byte;
    f: ticketFile;
    ticketData: ticketDataType;
    freeTickets: set of 1..MAXTICKETNUM;
begin
  if ticketsGrid.Selection.Top = 0 then begin
    messageDlg('Ошибка', 'Вы не выбрали билет', mtError, [mbOk], '');
    exit
  end;

  //считывание выбранного билета
  temp:= strToInt(ticketsGrid.Cells[0, ticketsGrid.Selection.Top]);

  //проверка на сущ-ие и доступность файла
  if validFile(FILENAME) then begin
    assignFile(f, FILENAME);

    //считывание данных о билетов
    ticketData:= getFileData(f);
  end else begin
    messageDlg('Ошибка', 'Файл недоступен, либо удален, либо поврежден, советуем создать новый файл билетов', mtError, [mbOk], '');
    exit
  end;

  //заполнение множества доступными билетами
  freeTickets:=[];
  for i:=1 to ticketData.freeTicketNum do
    freeTickets:=freeTickets+[ticketData.tickets[i]];

  //проверка на доступность билета
  if temp in freeTickets then begin
    messageDlg('Ошибка', 'Данный билет уже доступен', mtError, [mbOk], '');
    exit
  end;

  //пересчитывание кол-ва доступных билетов и добавление билета в конец массива
  ticketData.freeTicketNum:=ticketData.freeTicketNum+1;
  ticketData.tickets[ticketData.freeTicketNum]:=temp;

  //запись изменений
  setFileData(f, ticketData);

  //обновление списка
  tabClick(bTabList);

  ticketsGrid.row:=temp
end;

//пометить билет как выданный
procedure TfMain.bTakenTicketClick(Sender: TObject);
var temp, i: byte;
    f: ticketFile;
    ticketData: ticketDataType;
    freeTickets: set of 1..MAXTICKETNUM;
begin
  if ticketsGrid.Selection.Top = 0 then begin
    messageDlg('Ошибка', 'Вы не выбрали билет', mtError, [mbOk], '');
    exit
  end;

  //считывание выбранного билета
  temp:= strToInt(ticketsGrid.Cells[0, ticketsGrid.Selection.Top]);

  //проверка на сущ-ие и доступность файла
  if validFile(FILENAME) then begin
    assignFile(f, FILENAME);

    //считывание данных о билетов
    ticketData:= getFileData(f);
  end else begin
    messageDlg('Ошибка', 'Файл недоступен, либо удален, либо поврежден, советуем создать новый файл билетов', mtError, [mbOk], '');
    exit
  end;

  //заполнение множества доступными билетами
  freeTickets:=[];
  for i:=1 to ticketData.freeTicketNum do
    freeTickets:=freeTickets+[ticketData.tickets[i]];

  //проверка на статус билета
  if not (temp in freeTickets) then begin
    messageDlg('Ошибка', 'Данный билет уже выдан', mtError, [mbOk], '');
    exit
  end;

  //нахождение позиции билета
  i:=1;
  while (temp <> ticketData.tickets[i]) do
    i:=i+1;

  //удаление элемента
  deleteElement(i, ticketData.freeTicketNum, ticketData.tickets);

  //уменьшение кол-ва доступных билетов
  ticketData.freeTicketNum:=ticketData.freeTicketNum-1;

  //запись изменений
  setFileData(f, ticketData);

  //обновление списка
  tabClick(bTabList);

  ticketsGrid.row:=temp
end;
//------------------------------------------------------------------------------



//Вкладка - Настройки
//------------------------------------------------------------------------------
//кнопка сохранения
procedure TfMain.bSaveClick(Sender: TObject);
var group: string;
    f: ticketFile;
    ticketsData: ticketDataType;
begin
  //ввод группы
  if inputQuery('Группа', 'Введите группу:', group) then begin
    if group = '' then begin
      messageDlg('Ошибка', 'Вы ничего не ввели', mtError, [mbOK], '');
      exit
    end;

    sdTicket.fileName:='tickets_'+group+'.tsk';

    if sdTicket.Execute then begin
      //проверка на существование файла
      if fileExists(sdTicket.fileName) then
        //Решение пользователя
        if messageDlg('Подтверждение', 'Данный файл уже существует, желаете его перезаписать?', mtConfirmation,
                   [mbOK, mbCancel], '') = mrCancel
        then
          exit;

      //если файл валиден
      if validFile(FILENAME) then begin
        //считываение данных из файла
        assignFile(f, FILENAME);
        reset(f);
        read(f, ticketsData);
        closeFile(f);
      end else begin
        messageDlg('Ошибка', 'Файл не существует или был поврежден, советуем не сохранять его', mtError, [mbOK], '');
        exit
      end;

      //запись данных в новом файле
      assignFile(f, sdTicket.fileName);
      rewrite(f);
      write(f, ticketsData);
      closeFile(f)
    end
  end
end;

//кнопка загрузки
procedure TfMain.bLoadClick(Sender: TObject);
var f: ticketFile;
    ticketsData: ticketDataType;
begin
  //если файл уже есть и он действующий -> прледложение сохранить
  if validFile(FILENAME) then
    if messageDlg('Подтверждение', 'Хотите ли вы сохранить открытый ряд билетов?', mtConfirmation,
                  [mbOK, mbCancel], '') = mrOK
    then
      bSaveClick(bSave);

  if odTicket.Execute then begin
    //если файл валиден
      if validFile(odTicket.fileName) then begin
        //считываение данных из файла
        assignFile(f, odTicket.fileName);
        reset(f);
        read(f, ticketsData);
        closeFile(f);
      end else begin
        messageDlg('Ошибка', 'Файл не существует, был поврежден или неправильного формата, пожалуйста, выберите .tsk файл', mtError, [mbOK], '');
        exit
      end;

      //запись данных в новом файле
      assignFile(f, FILENAME);
      rewrite(f);
      write(f, ticketsData);
      closeFile(f)
  end
end;
//------------------------------------------------------------------------------

end.

