unit PseudoGraphic;

interface

uses crt;

type
  ComponentTypes = (ButtonType, TextFieldType, TableType, SelectType);
  AlignTypes = (AlignLeft, AlignCenter, AlignRight, AlignWidth);
  Select = record
    x, y: integer;
    width: integer;
    title: string;
    items: array of string;
    selected_index: integer;
    read_only: boolean;
  end;
  Button = record
    x, y: integer;
    onclick: procedure;
    title: string;
    text_color: byte := White;
    background_color: byte := Black;
  end;
  TextField = record
    x, y: integer;
    title: string;
    text_start: integer;
    cursor: integer;
    text_value: string;
    allow_numbers: boolean;
    allow_alphabet: boolean;
    allow_space: boolean;
    hide: boolean;
    width: integer;
    read_only: boolean;
  end;
  TextComponent = record
    x, y: integer;
    title: string;
    text_color: byte := White;
    background_color: byte := Black;
  end;
  Column = record
    name: string;
    width: integer;
    align: AlignTypes;
  end;
  Table = record
    columns: array of Column;
    active_rows: integer;
    count_rows: integer;
    rows_per_page: integer;
    get_row: function(i: integer): array of string;
    onclick_row: procedure(i: integer);
    ondelete_row: procedure(i: integer);
    read_only: boolean;
    current_page: integer;
    cursor: integer;
    title: string;
    x, y: integer;
    height: integer;
    width: integer;
  end;
  Assotiation = record
    index: integer;
    component_type: ComponentTypes;
    name: string;
  end;
  ListAssotiation = array of Assotiation;
  Window = record
    title: string;
  end;
  GuiComponents = record
    selects: array of Select;
    tables: array of Table;
    buttons: array of Button;
    text_fields: array of TextField;
    texts: array of TextComponent;
    window: Window;
    lstcomponents: ListAssotiation;
    stopped: boolean;
  end;


procedure FullRender(var a: GuiComponents);
procedure EventLoop(var a: GuiComponents);
function CreateColumn(name: string; width: integer; align: AlignTypes := AlignLeft): Column;
procedure RenderTextComponent(t: TextComponent);
procedure ClsSquare(x, y, width, height: integer);
function GetIndexByNameFromAssociationList(a: ListAssotiation; name: string): integer;

implementation
{Возвращает границы таблицы.
0 = верхний левый
1 = верхний
2 = верхний правый
3 = средний левый
4 = средний
5 = средний правый
6 = нижний левый
7 = нижний
8 = нижний правый
9 = горизонтальное соединение
10 = вертикальное соединение
+11 - с двойной линией
+22 - вертикальное соединение двойное
+33 - горизонтальное соединение двойное}
function GetBorderLine(i: integer): string;
const
  a: array of char = ('┌', '┬', '┐', '├', '┼', '┤', '└', '┴', '┘', '─', '│',
                          '╔', '╦', '╗', '╠', '╬', '╣', '╚', '╩', '╝', '═', '║',
                          '╓', '╥', '╖', '╟', '╫', '╢', '╙', '╨', '╜', '─', '║',
                          '╒', '╤', '╕', '╞', '╪', '╡', '╘', '╧', '╛', '═', '│');
begin
  GetBorderLine := a[i];
end;

function Normalize(s: string; l: integer; align: AlignTypes := AlignTypes.AlignLeft): string;
begin
  if s.length > l then s := Copy(s, 0, l - 2) + '..'
  else if s.length < l then
    if align = AlignLeft then s := s + ' ' * (l - s.length)
    else if align = AlignRight then s := ' ' * (l - s.length) + s
    else if align = AlignCenter then s := ' ' * trunc((l - s.length) / 2) + s + ' ' * ceil((l - s.length) / 2)
    else begin
      
    end;
  Result := s;
end;

function CreateColumn: Column;
var
  tmp: Column;
begin
  tmp.name := name;
  tmp.width := width;
  tmp.align := align;
  result := tmp;
end;

procedure ClsSquare(x, y, width, height: integer);
var
  i: integer;
begin
  for i := 0 to height - 1 do
  begin
    GotoXY(x, y + i);
    write(' ' * (width));
  end;
end;

function GetIndexByNameFromAssociationList(a: ListAssotiation; name: string): integer;
var
  i: integer;
begin
  GetIndexByNameFromAssociationList := -1;
  for i := 0 to high(a) do
    if a[i].name = name then begin
      GetIndexByNameFromAssociationList := a[i].index;
      break
    end;
end;

procedure FocusTextField(t: TextField);
begin
  with t do
    gotoxy(x + 1 + cursor, y + 1)
end;

procedure FocusSelect(t: Select);
begin
  with t do
    gotoxy(x + 1, y + 1)
end;

procedure FocusButton(t: Button; hide: boolean := False);
begin
  with t do
  begin
    gotoxy(x, y);
    TextColor(text_color);
    TextBackground(background_color);
    if hide then
      write('<')
    else
      write('>');
    gotoxy(x + title.Length + 1, y);
    if hide then
      write('>')
    else
      write('<');
    TextColor(White);
    TextBackground(Black);
  end;
end;

procedure FocusTable(t: Table; hide: boolean := False);
var
  ypos: integer;
begin
  with t do
  begin
    if count_rows > 0 then
      ypos := y + 4 + cursor * 2 // Местонахождение строки
    else
      ypos := y + 2; // Местонахождение колонки с названиями
    if not hide then begin
      gotoxy(x - 1, ypos);
      write('>');
      gotoxy(x + width, ypos);
      write('<');
    end
    else begin
      gotoxy(x - 1, ypos);
      write(' ');
      gotoxy(x + width, ypos);
      write(' ');
    end;
  end;
end;

procedure Focus(a: GuiComponents; i: integer; hide: boolean := false);
begin
  with a.lstcomponents[i] do
  begin
    if component_type = ComponentTypes.TextFieldType then
      FocusTextField(a.text_fields[index])
    else if component_type = ComponentTypes.ButtonType then
      FocusButton(a.buttons[index], hide)
    else if component_type = ComponentTypes.TableType then
      FocusTable(a.tables[index], hide)
    else if component_type = ComponentTypes.SelectType then
      FocusSelect(a.selects[index]);
  end;
  if hide then gotoxy(1, 1);
end;

procedure RenderContentTextField(t: TextField);
begin
  with t do
  begin
    gotoxy(x, y + 1);
    if text_start > 0 then
      write('<')
    else
      write(getborderline(10));
    if not hide then
      Write(Copy(text_value, text_start + 1, width - 2))
    else
      write('*' * Copy(text_value, text_start + 1, width - 2).Length);
    while wherex < x + width - 1 do write(' ');
    if (width - 2) < (text_value.Length - text_start) then
      write('>')
    else
      write(getborderline(10));
  end;
end;

procedure RenderContentSelect(t: Select);
begin
  with t do
  begin
    gotoxy(x, y + 1);
    if selected_index > 0 then
      write('<')
    else
      write(getborderline(10));
    Write(Normalize(items[selected_index], width - 2, AlignCenter));
    while wherex < x + width - 1 do write(' ');
    if selected_index < High(items) then
      write('>')
    else
      write(getborderline(10));
  end;
end;

procedure RenderContentTable(var t: Table);
var
  j, k: integer;
  row: array of string;
begin
  with t do
  begin
    ClsSquare(x, y + 3, width, height - 3);
    {Распечатка записей}
    if count_rows > 0 then begin
      rows_per_page := (height - 4) div 2;
      active_rows := Min(rows_per_page, count_rows - current_page);
      for k := 0 to active_rows - 1 do
      begin
        row := get_row(current_page + k);
        {Шапка строки}
        gotoxy(x, y + 3 + k * 2);
        write(GetBorderLine(3));
        for j := 0 to High(columns) do
        begin
          Write(getborderline(9) * columns[j].width);
          if j <> High(columns) then write(getborderline(4));
        end;
        write(getborderline(5));
        {Содержимое строки}
        gotoxy(x, y + 4 + k * 2);
        write(GetBorderLine(10));
        for j := 0 to High(columns) do
        begin
          Write(Normalize(row[j], columns[j].width, columns[j].align));
          if j <> High(columns) then write(getborderline(10));
        end;
        write(getborderline(10));
      end;
    end else active_rows := 0;
    {Закрытие таблицы}
    gotoxy(x, y + active_rows * 2 + 3);
    write(GetBorderLine(6));
    for j := 0 to High(columns) do
    begin
      Write(getborderline(9) * columns[j].width);
      if j <> High(columns) then write(getborderline(7));
    end;
    write(getborderline(8));
  end;
end;

procedure RenderContent(a: GuiComponents; i: integer);
begin
  with a.lstcomponents[i] do
  begin
    if component_type = ComponentTypes.TextFieldType then
      RenderContentTextField(a.text_fields[index])
    else if component_type = ComponentTypes.TableType then
      RenderContentTable(a.tables[index]);
  end;
end;

procedure RenderTextComponent(t: TextComponent);
begin
  with t do
  begin
    gotoxy(x, y);
    TextColor(text_color);
    TextBackground(background_color);
    write(title);
    TextBackground(Black);
    TextColor(White);
  end;
end;

procedure RenderTextField(t: TextField);
var
  {Временная переменная чтобы 2 раза не высчитывать одно и то же значение}
  free_space: real;
begin
  with t do
  begin
    {Верхняя границе текстового поля}
    gotoxy(x, y);
    free_space := (width - title.Length - 2) / 2;
    write(getborderline(0), getborderline(9) * trunc(free_space), title, getborderline(9) * ceil(free_space), getborderline(2));
    {Содержимое текстового поля}
    RenderContentTextField(t);
    {Нижняя граница текстового поля}
    gotoxy(x, y + 2);
    write(getborderline(6), getborderline(9) * (width - 2), getborderline(8));
  end;
end;

procedure RenderTable(var a: Table);
var
  j: integer;
begin
  with a do
  begin
    width := 0;
    for j := 0 to High(columns) do
    begin
      width := width + columns[j].width;
    end;
    width := width + 2 + High(columns);
    ClsSquare(x, y, width, 3);
    {Название таблицы}
    GotoXY(x, y);
    write(' ' * ((width - title.Length) div 2), title, ' ' * ((width - title.Length) div 2));
    {Шапка таблицы}
    gotoxy(x, y + 1);
    write(GetBorderLine(0));
    for j := 0 to High(columns) do
    begin
      Write(getborderline(9) * columns[j].width);
      if j <> High(columns) then write(getborderline(1));
    end;
    write(getborderline(2));
    {Наименование колонок}
    gotoxy(x, y + 2);
    write(GetBorderLine(10));
    for j := 0 to High(columns) do
    begin
      Write(Normalize(columns[j].name, columns[j].width, columns[j].align));
      if j <> High(columns) then write(getborderline(10));
    end;
    write(getborderline(10));
    RenderContentTable(a);
  end;
end;

procedure RenderButton(t: Button);
begin
  with t do
  begin
    gotoxy(x, y);
    TextColor(text_color);
    TextBackground(background_color);
    write('<', title, '>');
    TextColor(White);
    TextBackground(Black);
  end;
end;

procedure RenderSelect(t: Select);
var
  {Временная переменная чтобы 2 раза не высчитывать одно и то же значение}
  free_space: real;
begin
  with t do
  begin
    {Верхняя границе текстового поля}
    gotoxy(x, y);
    free_space := (width - title.Length - 2) / 2;
    write(getborderline(0), getborderline(9) * trunc(free_space), title, getborderline(9) * ceil(free_space), getborderline(2));
    {Содержимое текстового поля}
    RenderContentSelect(t);
    {Нижняя граница текстового поля}
    gotoxy(x, y + 2);
    write(getborderline(6), getborderline(9) * (width - 2), getborderline(8));
  end;
end;

procedure RenderWindow(t: Window);
var
  i: integer;
  free_space: real;
begin
  with t do
  begin
    free_space := (WindowWidth - 2 - title.Length) / 2;
    write(getborderline(11), getborderline(20) * trunc(free_space), title, getborderline(20) * ceil(free_space), getborderline(13));
    for i := 1 to WindowHeight - 2 do
      write(getborderline(21), ' ' * (WindowWidth - 2), getborderline(21));
    write(getborderline(17), getborderline(20) * (WindowWidth - 2), getborderline(19));
  end;
end;

procedure FullRender(var a: GuiComponents);
var
  i: integer;
begin
  ClrScr;
  // Рендер нефункциональных, визуальных компонентов
  // Рендер окна
  RenderWindow(a.window);
  for i := 0 to High(a.texts) do
    RenderTextComponent(a.texts[i]);
  // Рендер функциональных компонентов
  for i := 0 to High(a.lstcomponents) do
  begin
    with a.lstcomponents[i] do
    begin
      if component_type = ComponentTypes.TextFieldType then 
        RenderTextField(a.text_fields[index])
      else if component_type = ComponentTypes.ButtonType then 
        RenderButton(a.buttons[index])
      else if component_type = ComponentTypes.TableType then
        RenderTable(a.tables[index])
      else if component_type = ComponentTypes.SelectType then
        RenderSelect(a.selects[index]);
    end;
  end;
  // Возврат в начало
  gotoxy(1, 1);
end;

procedure OnKeyTextField(key: char; var t: TextField);
begin
  with t do
  begin
    {Проверка для символов, цифр}
    if not read_only and (allow_alphabet and ((key in ['a'..'z']) or (key in ['а'..'я']) or (key in ['A'..'Z']) or (key in ['А'..'Я'])) or (key in ['0'..'9']) and allow_numbers or allow_space and (key = ' ')) then begin
      Insert(key, text_value, text_start + cursor + 1);
      if cursor > (width - 4) then begin
        inc(text_start);
      end else begin
        inc(cursor);
      end;
      RenderContentTextField(t);
      FocusTextField(t);
      {Проверка на стрелку влево}
    end else if (key = #37) and ((text_start > 0) or (cursor > 0)) then begin
      if cursor = 0 then begin
        dec(text_start);
        RenderContentTextField(t);
      end else begin
        dec(cursor);
      end;
      FocusTextField(t)
      {Проверка на стрелку вправо}
    end else if (key = #39) and ((text_value.Length - text_start - 1 > width - 4) and (cursor > width - 4) or (text_value.Length - text_start - cursor > 0)) then begin
      if cursor > width - 4 then begin
        inc(text_start);
        RenderContentTextField(t);
      end else
        inc(cursor);
      FocusTextField(t);
      {Проверка на удаление символа}
    end else if not read_only and (key = #8) and ((cursor > 0) or (text_start > 0)) then begin
      delete(text_value, text_start + cursor, 1);
      if cursor > 0 then dec(cursor)
      else if text_start > 0 then dec(text_start);
      RenderContentTextField(t);
      FocusTextField(t);
    end;
  end;
end;

procedure OnKeySelect(key: char; var t: Select);
begin
  with t do
  begin
    {Проверка для символов, цифр}
    if not read_only and (key = #37) and (selected_index > 0) then begin
      dec(selected_index);
      RenderContentSelect(t);
    end else if not read_only and (key = #39) and (selected_index < high(items)) then begin
      inc(selected_index);
      RenderContentSelect(t);
    end
  end;
end;

procedure OnKeyTable(key: char; var t: Table);
begin
  with t do
  begin
    if key = #45 then begin
      if cursor > 0 then begin
        FocusTable(t, true);
        dec(cursor);
        FocusTable(t);
      end else if current_page > 0 then begin
        current_page := max(current_page - rows_per_page, 0);
        FocusTable(t, true);
        cursor := 0;
        RenderTable(t);
        FocusTable(t);
      end;
    end else if key = #43 then begin
      if cursor < active_rows - 1 then begin
        FocusTable(t, true);
        inc(cursor);
        FocusTable(t);
      end else if count_rows > active_rows + current_page then begin
        current_page := current_page + rows_per_page;
        FocusTable(t, true);
        RenderTable(t);
        cursor := active_rows - 1;
        FocusTable(t);
      end
    end else if (key = #13) and (count_rows > 0) then begin
      onclick_row(current_page + cursor);
      FocusTable(t);
    end else if not read_only and (key = #46) and (count_rows > 0) then begin
      ondelete_row(current_page + cursor);
      FocusTable(t);
    end;
  end;
end;

procedure OnKeyButton(key: char; var t: Button);
begin
  with t do
  begin
    if (key = #13) then begin
      onclick();
    end;
  end;
end;

procedure OnKey(key: char; var a: GuiComponents; i: integer);
begin
  with a.lstcomponents[i] do
  begin
    if component_type = ComponentTypes.TextFieldType then 
      OnKeyTextField(key, a.text_fields[index])
    else if component_type = ComponentTypes.TableType then
      OnKeyTable(key, a.tables[index])
    else if component_type = ComponentTypes.ButtonType then
      OnKeyButton(key, a.buttons[index])
    else if component_type = ComponentTypes.SelectType then
      OnKeySelect(key, a.selects[index]);
    if (not a.stopped) and (key = #13) then
      Focus(a, i);
  end;
end;

function mod_(a, b: integer): integer;
var
  k: integer;
begin
  k := a mod b;
  if k >= 0 then mod_ := k
  else mod_ := b + k;
end;

procedure EventLoop(var a: GuiComponents);
var
  i: integer;
  key: char;
begin
  i := 0;
  Focus(a, i);
  while not a.stopped do
  begin
    key := ReadKey;
    //print(ord(key));
    //print(i);
    if (key in [#9, #40, #38]) and (a.lstcomponents[i].component_type in [ComponentTypes.ButtonType, ComponentTypes.TableType]) then Focus(a, i, true);
    if key = #38 then i := mod_(i - 1, a.lstcomponents.Length)
    else if key = #40 then i := mod_(i + 1, a.lstcomponents.Length)
    else if key = #9 then i := mod_(i + 1, a.lstcomponents.Length)
    else onkey(key, a, i);
    if key in [#9, #40, #38] then Focus(a, i);
    //GotoXY(2, 22);
    //write(cursor);
  end;
end;

begin
end. 