unit PseudoGraphic;

interface

uses crt;

type
  Button = record
    x, y: integer;
    onclick: procedure;
    title: string;
    color: integer;
  end;
  TextField = record
    x, y: integer;
    title: string;
    text_start: integer;
    cursor: integer;
    text_value: string;
    allow_numbers: boolean;
    hide: boolean;
    width: integer;
  end;
  TextComponent = record
    x, y: integer;
    title: string;
  end;
  Column = record
    name: string;
    width: integer;
  end;
  Table = record
    columns: array of Column;
    active_rows: integer;
    count_rows: integer;
    rows_per_page: integer;
    get_row: function(i: integer): array of string;
    onclick_row: procedure(i: integer);
    ondelete_row: procedure(i: integer);
    current_page: integer;
    cursor: integer;
    title: string;
    x, y: integer;
    height: integer;
    width: integer;
  end;
  Assotiation = record
    index: integer;
    component_type: string;
  end;
  ListAssotiation = array of Assotiation;
  Window = record
    title: string;
  end;
  GuiComponents = record
    tables: array of Table;
    buttons: array of Button;
    text_fields: array of TextField;
    texts: array of TextComponent;
    window: Window;
    lstcomponents: ListAssotiation;
    res: integer;
    stopped: boolean;
  end;

procedure FullRender(var a: GuiComponents);
procedure EventLoop(var a: GuiComponents);
function CreateColumn(name: string; width: integer): Column;

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

function Normalize(s: string; l: integer): string;
begin
  if s.length > l then s := Copy(s, 0, l - 2) + '..'
  else if s.length < l then s := s + ' ' * (l - s.length);
  Result := s;
end;

function CreateColumn(name: string; width: integer): Column;
var
  tmp: Column;
begin
  tmp.name := name;
  tmp.width := width;
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

procedure Focus(a: GuiComponents; i: integer; hide: boolean := false);
begin
  with a.lstcomponents[i] do
  begin
    if component_type = 'text_field' then begin
      with a.text_fields[index] do
        gotoxy(x + 1 + cursor, y + 1)
    end else if component_type = 'button' then begin
      with a.buttons[index] do
      begin
        gotoxy(x, y);
        TextColor(color);
        if hide then
          write('<')
        else
          write('>');
        write(title);
        if hide then
          write('>')
        else
          write('<');
        textcolor(white);
      end;
    end else if component_type = 'table' then begin
      with a.tables[index] do
      begin
        if not hide then begin
          gotoxy(x - 1, y + 4 + cursor * 2);
          write('>');
          gotoxy(x + width, y + 4 + cursor * 2);
          write('<');
        end
        else begin
          gotoxy(x - 1, y + 4 + cursor * 2);
          write(' ');
          gotoxy(x + width, y + 4 + cursor * 2);
          write(' ');
        end;
      end;
    end;
  end;
end;

procedure RenderContent(a: GuiComponents; i: integer);
begin
  with a.lstcomponents[i] do
  begin
    if component_type = 'text_field' then begin
      with a.text_fields[index] do
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
  end;
end;

procedure RenderTable(var a: Table);
var
  j, k: integer;
  row: array of string;
begin
  with a do
  begin
    width := 0;
    for j := 0 to High(columns) do
    begin
      width := width + columns[j].width;
    end;
    width := width + 2 + High(columns);
    ClsSquare(x, y, width, height);
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
      Write(Normalize(columns[j].name, columns[j].width));
      if j <> High(columns) then write(getborderline(10));
    end;
    write(getborderline(10));
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
          Write(Normalize(row[j], columns[j].width));
          if j <> High(columns) then write(getborderline(10));
        end;
        write(getborderline(10));
      end;
    end;
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

procedure FullRender(var a: GuiComponents);
var
  i: integer;
begin
  ClrScr;
  write(getborderline(11), getborderline(20) * trunc((WindowWidth - 2 - a.window.title.Length) / 2), a.window.title, getborderline(20) * ceil((WindowWidth - 2 - a.window.title.Length) / 2), getborderline(13));
  for i := 1 to WindowHeight - 2 do write(getborderline(21), ' ' * (WindowWidth - 2), getborderline(21));
  write(getborderline(17), getborderline(20) * (WindowWidth - 2), getborderline(19));
  for i := 0 to High(a.texts) do
  begin
    with a.texts[i] do
    begin
      gotoxy(x, y);
      write(title);
    end;
  end;
  for i := 0 to High(a.lstcomponents) do
  begin
    with a.lstcomponents[i] do
    begin
      if component_type = 'text_field' then begin
        with a.text_fields[index] do
        begin
          gotoxy(x, y);
          write(getborderline(0), getborderline(9) * trunc((width - title.Length - 2) / 2), title, getborderline(9) * ceil((width - title.Length - 2) / 2), getborderline(2));
          RenderContent(a, i);
          gotoxy(x, y + 2);
          write(getborderline(6), getborderline(9) * (width - 2), getborderline(8));
        end;
      end else if component_type = 'button' then begin
        with a.buttons[index] do
        begin
          gotoxy(x, y);
          TextColor(color);
          write('<', title, '>');
          textcolor(White);
        end;
      end else if component_type = 'table' then begin
        RenderTable(a.tables[index]);
      end;
    end;
  end;
  gotoxy(1, 1);
end;

function OnKey(key: char; var a: GuiComponents; i: integer): integer;
begin
  with a.lstcomponents[i] do
  begin
    OnKey := 0;
    if component_type = 'text_field' then begin
      with a.text_fields[index] do
      begin
        if (key in ['a'..'z']) or (key in ['а'..'я']) or (key in ['A'..'Z']) or (key in ['А'..'Я']) or (key in ['0'..'9']) and allow_numbers then begin
          Insert(key, text_value, text_start + cursor + 1);
          if cursor > (width - 4) then begin
            inc(text_start);
            RenderContent(a, i);
            Focus(a, i);
          end else begin
            inc(cursor);
            RenderContent(a, i);
            Focus(a, i);
          end;
        end else if key = #37 then begin
          if (text_start > 0) or (cursor > 0) then
            if cursor = 0 then begin
              dec(text_start);
              RenderContent(a, i);
              Focus(a, i);
            end else begin
              dec(cursor);
              Focus(a, i);
            end;
        end else if key = #39 then begin
          if (cursor > width - 4) and (text_value.Length - text_start - 1 > width - 4) then begin
            inc(text_start);
            RenderContent(a, i);
            Focus(a, i);
          end else if (cursor < width - 3) and (text_value.Length - text_start - cursor > 0) then begin
            inc(cursor);
            Focus(a, i);
          end;
        end else if key = #8 then begin
          if (cursor > 0) or (text_start > 0) then begin
            delete(text_value, text_start + cursor, 1);
            if cursor > 0 then dec(cursor)
            else if text_start > 0 then dec(text_start);
            RenderContent(a, i);
            Focus(a, i);
          end;
        end;
      end;
    end else if component_type = 'table' then begin
      with a.tables[index] do
      begin
        if key = #45 then begin
          if cursor > 0 then begin
            Focus(a, i, true);
            dec(cursor);
            Focus(a, i);
          end else if current_page > 0 then begin
            current_page := max(current_page - rows_per_page, 0);
            focus(a, i, true);
            cursor := 0;
            RenderTable(a.tables[index]);
            focus(a, i);
          end;
        end else if key = #43 then begin
          if cursor < active_rows - 1 then begin
            Focus(a, i, true);
            inc(cursor);
            Focus(a, i);
          end else if count_rows > active_rows + current_page then begin
            current_page := current_page + rows_per_page;
            Focus(a, i, true);
            RenderTable(a.tables[index]);
            cursor := active_rows - 1;
            Focus(a, i);
          end;
        end;
      end;
    end else if component_type = 'button' then begin
      with a.buttons[index] do
      begin
        if (key = #13) then begin
          onclick();
        end;
      end;
    end;
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
    if (key in [#9, #40, #38]) and ((a.lstcomponents[i].component_type = 'button') or (a.lstcomponents[i].component_type = 'table')) then Focus(a, i, true);
    if key = #38 then i := mod_(i - 1, a.lstcomponents.Length)
    else if key = #40 then i := mod_(i + 1, a.lstcomponents.Length)
    {if key = #9 then i := mod_(i + 1, a.lstcomponents.Length)}
    else onkey(key, a, i);
    if key in [#9, #40, #38] then Focus(a, i);
    //GotoXY(2, 22);
    //write(cursor);
  end;
end;

procedure PushToArray<T>(a: array of T; val: T);
var
  l: integer;
begin
  try
    l := 1 + a.Length
  except
    l := 1;
  end;
  setlength(a, l);
  a[mod_(-1, a.Length)] := val;
end;

begin
end. 