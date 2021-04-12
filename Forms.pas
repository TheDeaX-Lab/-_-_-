unit Forms;

interface

uses crt, PseudoGraphic, Authentication;

function CreateAuthForm: GuiComponents;
function CreateMenuForm(account: account_rec): GuiComponents;
function CreateStartMenu(): GuiComponents;

implementation

function CreateAuthForm: GuiComponents;
var
  tmp: GuiComponents;
  i, bn, tn, tbn: integer;
begin
  with tmp do
  begin
    window.title := 'Авторизация';
    SetLength(lstcomponents, 4);
    SetLength(buttons, 2);
    SetLength(text_fields, 2);
    {Описание текстового поля для ввода логина}
    with text_fields[tn] do
    begin
      title := 'Логин';
      y := trunc(WindowHeight / 2) - 3;
      x := trunc(WindowWidth / 2) - 25;
      width := 50;
    end;
    with lstcomponents[i] do
    begin
      index := tn;
      component_type := 'text_field';
    end;
    inc(tn);
    inc(i);
    {Описание текстового поля для ввода пароля}
    with text_fields[tn] do
    begin
      title := 'Пароль';
      y := trunc(WindowHeight / 2);
      x := trunc(WindowWidth / 2) - 25;
      width := 50;
      hide := true;
      allow_numbers := true;
    end;
    with lstcomponents[i] do
    begin
      index := tn;
      component_type := 'text_field';
    end;
    inc(tn);
    inc(i);
    {Описание кнопки которая проверит текстовые поля}
    with buttons[bn] do
    begin
      y := trunc(WindowHeight / 2) + 3;
      x := trunc(WindowWidth / 2) - 4;
      title := 'Войти';
      color := Green;
    end;
    with lstcomponents[i] do
    begin
      index := bn;
      component_type := 'button';
    end;
    inc(bn);
    inc(i);
    {Описание кнопки для того чтобы выйти из программы}
    with buttons[bn] do
    begin
      y := trunc(WindowHeight / 2) + 5;
      x := trunc(WindowWidth / 2) - 4;
      title := 'Выйти';
      color := Red;
    end;
    with lstcomponents[i] do
    begin
      index := bn;
      component_type := 'button';
    end;
    inc(bn);
    inc(i);
  end;
  Result := tmp;
end;

function CreateMenuForm: GuiComponents;
var
  tmp: GuiComponents;
  i, bn, n: integer;
begin
  with tmp do
  begin
    window.title := 'Меню';
    n := 2;
    if account.admin = 1 then Inc(n);
    SetLength(lstcomponents, n);
    SetLength(buttons, n);
    {Описание кнопки для открытия окна просмотра таблиц студентов}
    with buttons[bn] do
    begin
      y := trunc(WindowHeight / 2) - 3;
      if account.admin <> 1 then y := y + 3;
      title := 'Просмотр таблиц студентов';
      x := trunc(WindowWidth / 2) - trunc(title.Length / 2);
      color := LightBlue;
    end;
    with lstcomponents[i] do
    begin
      index := bn;
      component_type := 'button';
    end;
    inc(i);
    inc(bn);
    if account.admin = 1 then begin
      {Описание кнопки для открытия окна просмотра таблиц аккаунтов}
      with buttons[bn] do
      begin
        y := trunc(WindowHeight / 2);
        title := 'Просмотр таблиц аккаунтов';
        x := trunc(WindowWidth / 2) - trunc(title.Length / 2);
        color := LightRed;
      end;
      with lstcomponents[i] do
      begin
        index := bn;
        component_type := 'button';
      end;
      inc(i);
      inc(bn);
    end;
    {Описание кнопки для выхода из сессии}
    with buttons[bn] do
    begin
      y := trunc(WindowHeight / 2) + 3;
      title := 'Выйти из сессии';
      x := trunc(WindowWidth / 2) - trunc(title.Length / 2);
      color := Red;
    end;
    with lstcomponents[i] do
    begin
      index := bn;
      component_type := 'button';
    end;
    inc(i);
    inc(bn);
  end;
  Result := tmp;
end;

function CreateStartMenu(): GuiComponents;
var tmp : GuiComponents;
begin
  with tmp do begin
    window.title := 'Стартовое меню';
    SetLength(texts, 19);
    with texts[0] do begin
      title := 'Министерство науки и высшего образования Российской Федерации';
      x := (WindowWidth - title.Length) div 2;
      y := 2;
    end;
    with texts[1] do begin
      title := 'Федеральное государственное бюджетное образовательное учреждение';
      x := (WindowWidth - title.Length) div 2;
      y := 3;
    end;
    with texts[2] do begin
      title := 'высшего образования "Рязанский государственный радиотехнический';
      x := (WindowWidth - title.Length) div 2;
      y := 4;
    end;
    with texts[3] do begin
      title := 'университет имени В.Ф. Уткина"';
      x := (WindowWidth - title.Length) div 2;
      y := 5;
    end;
    with texts[4] do begin
      title := 'кафедра "ЭВМ"';
      x := (WindowWidth - title.Length) div 2;
      y := 6;
    end;
    with texts[5] do begin
      title := 'Курсовая работа';
      x := (WindowWidth - title.Length) div 2;
      y := 10;
    end;
    with texts[6] do begin
      title := 'По теме';
      x := (WindowWidth - title.Length) div 2;
      y := 11;
    end;
    with texts[7] do begin
      title := '"Информационные системы, Стипендия"';
      x := (WindowWidth - title.Length) div 2;
      y := 12;
    end;
    with texts[8] do begin
      title := 'По дисциплине';
      x := (WindowWidth - title.Length) div 2;
      y := 13;
    end;
    with texts[9] do begin
      title := '"Алгоритмические языки и программирование"';
      x := (WindowWidth - title.Length) div 2;
      y := 14;
    end;
    with texts[10] do begin
      title := 'Выполнил:';
      x := WindowWidth - title.Length - 1;
      y := WindowHeight - 9;
    end;
    with texts[11] do begin
      title := 'Студент группы 045 ЭВМ';
      x := WindowWidth - title.Length - 1;
      y := WindowHeight - 8;
    end;
    with texts[12] do begin
      title := 'Харитонов А.А.';
      x := WindowWidth - title.Length - 1;
      y := WindowHeight - 7;
    end;
    with texts[13] do begin
      title := 'Проверили:';
      x := WindowWidth - title.Length - 1;
      y := WindowHeight - 5;
    end;
    with texts[14] do begin
      title := 'Доц.Каф. ВПМ';
      x := WindowWidth - title.Length - 1;
      y := WindowHeight - 4;
    end;
    with texts[15] do begin
      title := 'Макаров Н.П.';
      x := WindowWidth - title.Length - 1;
      y := WindowHeight - 3;
    end;
    with texts[16] do begin
      title := 'С.П.Каф. ВПМ';
      x := WindowWidth - title.Length - 1;
      y := WindowHeight - 2;
    end;
    with texts[17] do begin
      title := 'Москвитина О.А.';
      x := WindowWidth - title.Length - 1;
      y := WindowHeight - 1;
    end;
    with texts[18] do begin
      title := 'Рязань 2021';
      x := (WindowWidth - title.Length) div 2;
      y := WindowHeight;
    end;
  end;
  Result := tmp;
end;

begin

end. 