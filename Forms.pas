unit Forms;

interface

uses crt, PseudoGraphic, Authentication;

function CreateAuthForm: GuiComponents;
function CreateMenuForm(account: account_rec): GuiComponents;
function CreateStartMenu(): GuiComponents;
function CreateAccountsForm(): GuiComponents;
function CreateAccountForm(): GuiComponents;
function CreateApplyForm(): GuiComponents;
function CreateStudentsForm(account: account_rec): GuiComponents;
function CreateStudentForm(account: account_rec; is_add: boolean := false): GuiComponents;
function CreateDisciplinesForm(): GuiComponents;
function CreateDisciplineForm(): GuiComponents;
function CreateBaseStipendiaForm(): GuiComponents;
function CreateMarkForm(account: account_rec): GuiComponents;
function CreateMarksForm(account: account_rec; is_denied_marks: boolean): GuiComponents;

implementation

function CreateAuthForm: GuiComponents;
var
  tmp: GuiComponents;
  i, bn, tn: integer;
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
      allow_alphabet := true;
      width := 50;
    end;
    with lstcomponents[i] do
    begin
      index := tn;
      component_type := ComponentTypes.TextFieldType;
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
      allow_alphabet := true;
      allow_numbers := true;
    end;
    with lstcomponents[i] do
    begin
      index := tn;
      component_type := ComponentTypes.TextFieldType;
    end;
    inc(tn);
    inc(i);
    {Описание кнопки которая проверит текстовые поля}
    with buttons[bn] do
    begin
      y := trunc(WindowHeight / 2) + 3;
      x := trunc(WindowWidth / 2) - 4;
      title := 'Войти';
      text_color := Green;
    end;
    with lstcomponents[i] do
    begin
      index := bn;
      component_type := ComponentTypes.ButtonType;
    end;
    inc(bn);
    inc(i);
    {Описание кнопки для того чтобы выйти из программы}
    with buttons[bn] do
    begin
      y := trunc(WindowHeight / 2) + 5;
      x := trunc(WindowWidth / 2) - 4;
      title := 'Выйти';
      text_color := LightRed;
    end;
    with lstcomponents[i] do
    begin
      index := bn;
      component_type := ComponentTypes.ButtonType;
    end;
    inc(bn);
    inc(i);
  end;
  Result := tmp;
end;

function CreateMenuForm: GuiComponents;
var
  tmp: GuiComponents;
  i, bn, n, nd: integer;
begin
  with tmp do
  begin
    window.title := 'Меню';
    n := 2;
    if account.admin = 1 then n := n + 3;
    nd := n div 2;
    SetLength(lstcomponents, n);
    SetLength(buttons, n);
    {Описание кнопки для открытия окна просмотра таблиц студентов}
    with buttons[bn] do
    begin
      y := trunc(WindowHeight / 2) - 3 * (nd - bn);
      title := 'Просмотр студентов';
      x := trunc(WindowWidth / 2) - trunc(title.Length / 2);
      text_color := Crt.LightCyan;
    end;
    with lstcomponents[i] do
    begin
      name := 'open_students_table';
      index := bn;
      component_type := ComponentTypes.ButtonType;
    end;
    inc(i);
    inc(bn);
    if account.admin = 1 then begin
      {Описание кнопки для открытия окна просмотра таблиц аккаунтов}
      with buttons[bn] do
      begin
        y := trunc(WindowHeight / 2) - 3 * (nd - bn);
        title := 'Просмотр аккаунтов';
        x := trunc(WindowWidth / 2) - trunc(title.Length / 2);
        text_color := LightRed;
      end;
      with lstcomponents[i] do
      begin
        name := 'open_accounts_table';
        index := bn;
        component_type := ComponentTypes.ButtonType;
      end;
      inc(i);
      inc(bn);
    end;
    {Описание кнопки для просмотра существующих дисциплин}
    if account.admin = 1 then begin
      with buttons[bn] do
      begin
        y := trunc(WindowHeight / 2) - 3 * (nd - bn);
        title := 'Просмотр всех зарегистрированных дисциплин';
        x := trunc(WindowWidth / 2) - trunc(title.Length / 2);
        text_color := LightRed;
      end;
      with lstcomponents[i] do
      begin
        name := 'open_disciplines_table';
        index := bn;
        component_type := ComponentTypes.ButtonType;
      end;
      inc(i);
      inc(bn);
    end;
    {Описание кнопки для редактирования базовой стипендии}
    if account.admin = 1 then begin
      with buttons[bn] do
      begin
        y := trunc(WindowHeight / 2) - 3 * (nd - bn);
        title := 'Изменить значение базовой стипендии';
        x := trunc(WindowWidth / 2) - trunc(title.Length / 2);
        text_color := LightRed;
      end;
      with lstcomponents[i] do
      begin
        name := 'open_stipendia_form';
        index := bn;
        component_type := ComponentTypes.ButtonType;
      end;
      inc(i);
      inc(bn);
    end;
    {Описание кнопки для выхода из сессии}
    with buttons[bn] do
    begin
      y := trunc(WindowHeight / 2) - 3 * (nd - bn);
      title := 'Выйти из сессии';
      x := trunc(WindowWidth / 2) - trunc(title.Length / 2);
      text_color := LightRed;
    end;
    with lstcomponents[i] do
    begin
      name := 'exit_button';
      index := bn;
      component_type := ComponentTypes.ButtonType;
    end;
    inc(i);
    inc(bn);
  end;
  Result := tmp;
end;

function CreateStartMenu(): GuiComponents;
var
  tmp: GuiComponents;
begin
  with tmp do
  begin
    window.title := 'Стартовое меню';
    SetLength(texts, 19);
    with texts[0] do
    begin
      title := 'Министерство науки и высшего образования Российской Федерации';
      x := (WindowWidth - title.Length) div 2;
      y := 2;
    end;
    with texts[1] do
    begin
      title := 'Федеральное государственное бюджетное образовательное учреждение';
      x := (WindowWidth - title.Length) div 2;
      y := 3;
    end;
    with texts[2] do
    begin
      title := 'высшего образования "Рязанский государственный радиотехнический';
      x := (WindowWidth - title.Length) div 2;
      y := 4;
    end;
    with texts[3] do
    begin
      title := 'университет имени В.Ф. Уткина"';
      x := (WindowWidth - title.Length) div 2;
      y := 5;
    end;
    with texts[4] do
    begin
      title := 'кафедра "ЭВМ"';
      x := (WindowWidth - title.Length) div 2;
      y := 6;
    end;
    with texts[5] do
    begin
      title := 'Курсовая работа';
      x := (WindowWidth - title.Length) div 2;
      y := 10;
    end;
    with texts[6] do
    begin
      title := 'По теме';
      x := (WindowWidth - title.Length) div 2;
      y := 11;
    end;
    with texts[7] do
    begin
      title := '"Информационные системы, Стипендия"';
      x := (WindowWidth - title.Length) div 2;
      y := 12;
    end;
    with texts[8] do
    begin
      title := 'По дисциплине';
      x := (WindowWidth - title.Length) div 2;
      y := 13;
    end;
    with texts[9] do
    begin
      title := '"Алгоритмические языки и программирование"';
      x := (WindowWidth - title.Length) div 2;
      y := 14;
    end;
    with texts[10] do
    begin
      title := 'Выполнил:';
      x := WindowWidth - title.Length - 1;
      y := WindowHeight - 9;
    end;
    with texts[11] do
    begin
      title := 'Студент группы 045 ЭВМ';
      x := WindowWidth - title.Length - 1;
      y := WindowHeight - 8;
    end;
    with texts[12] do
    begin
      title := 'Харитонов А.А.';
      x := WindowWidth - title.Length - 1;
      y := WindowHeight - 7;
    end;
    with texts[13] do
    begin
      title := 'Проверили:';
      x := WindowWidth - title.Length - 1;
      y := WindowHeight - 5;
    end;
    with texts[14] do
    begin
      title := 'Доц.Каф. ВПМ';
      x := WindowWidth - title.Length - 1;
      y := WindowHeight - 4;
    end;
    with texts[15] do
    begin
      title := 'Макаров Н.П.';
      x := WindowWidth - title.Length - 1;
      y := WindowHeight - 3;
    end;
    with texts[16] do
    begin
      title := 'С.П.Каф. ВПМ';
      x := WindowWidth - title.Length - 1;
      y := WindowHeight - 2;
    end;
    with texts[17] do
    begin
      title := 'Москвитина О.А.';
      x := WindowWidth - title.Length - 1;
      y := WindowHeight - 1;
    end;
    with texts[18] do
    begin
      title := 'Рязань 2021';
      x := (WindowWidth - title.Length) div 2;
      y := WindowHeight;
    end;
  end;
  Result := tmp;
end;

function CreateAccountsForm(): GuiComponents;
var
  i, bn, tb, free_space, busy_space: integer;
  tmp: GuiComponents;
begin
  SetLength(tmp.tables, 1);
  setlength(tmp.buttons, 2);
  setlength(tmp.lstcomponents, 3);
  tmp.window.title := 'Просмотр таблицы аккаунтов';
  with tmp.tables[tb] do
  begin
    setlength(columns, 3);
    free_space := WindowWidth - 4 - 4;
    busy_space := trunc(free_space / 3);
    free_space := free_space - busy_space;
    columns[0] := CreateColumn('Логин', busy_space, AlignCenter);
    busy_space := ceil(free_space / 2);
    free_space := free_space - busy_space;
    columns[1] := CreateColumn('Пароль', busy_space, AlignCenter);
    columns[2] := CreateColumn('Администратор', free_space, AlignCenter);
    
    height := WindowHeight - 3 - 3;
    x := 3;
    y := 3;
    title := 'Аккаунты';
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'accounts_table';
    index := tb;
    component_type := ComponentTypes.TableType;
  end;
  inc(i);
  inc(tb);
  with tmp.buttons[bn] do
  begin
    title := 'Выйти';
    x := (WindowWidth div 2 - title.Length - 2) div 2;
    y := WindowHeight - 2;
    text_color := LightRed;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'exit_button';
    index := bn;
    component_type := ComponentTypes.ButtonType;
  end;
  inc(i);
  inc(bn);
  with tmp.buttons[bn] do
  begin
    title := 'Добавить новый аккаунт';
    x := (WindowWidth div 2 - title.Length - 2) div 2 + WindowWidth div 2;
    y := WindowHeight - 2;
    text_color := Green;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'add_account';
    index := bn;
    component_type := ComponentTypes.ButtonType;
  end;
  inc(i);
  inc(bn);
  Result := tmp;
end;

function CreateAccountForm(): GuiComponents;
var
  i, bn, tf, sl: integer;
  tmp: GuiComponents;
begin
  SetLength(tmp.selects, 1);
  setlength(tmp.buttons, 2);
  setlength(tmp.text_fields, 2);
  setlength(tmp.lstcomponents, 5);
  tmp.window.title := 'Замените название на своё действие';
  with tmp.text_fields[tf] do
  begin
    title := 'Логин';
    x := 2;
    y := 4;
    width := WindowWidth - 2;
    allow_alphabet := true;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'login_field';
    index := tf;
    component_type := ComponentTypes.TextFieldType;
  end;
  inc(i);
  inc(tf);
  with tmp.text_fields[tf] do
  begin
    title := 'Пароль';
    x := 2;
    y := 8;
    allow_alphabet := true;
    allow_numbers := true;
    width := WindowWidth - 2;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'password_field';
    index := tf;
    component_type := ComponentTypes.TextFieldType;
  end;
  inc(i);
  inc(tf);
  with tmp.selects[sl] do
  begin
    title := 'Администратор?';
    x := 2;
    y := 12;
    width := WindowWidth - 2;
    setlength(items, 2);
    items[0] := 'Нет';
    items[1] := 'Да';
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'admin_field';
    index := sl;
    component_type := ComponentTypes.SelectType;
  end;
  inc(i);
  inc(sl);
  with tmp.buttons[bn] do
  begin
    title := 'Отмена';
    x := (WindowWidth div 2 - title.Length - 2) div 2;
    y := WindowHeight - 2;
    text_color := LightRed;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'exit_button';
    index := bn;
    component_type := ComponentTypes.ButtonType;
  end;
  inc(i);
  inc(bn);
  with tmp.buttons[bn] do
  begin
    title := 'Замените название на своё действие';
    x := (WindowWidth div 2 - title.Length - 2) div 2 + WindowWidth div 2;
    y := WindowHeight - 2;
    text_color := Green;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'action';
    index := bn;
    component_type := ComponentTypes.ButtonType;
  end;
  inc(i);
  inc(bn);
  Result := tmp;
end;

function CreateApplyForm(): GuiComponents;
var
  i, bn, tx: integer;
  tmp: GuiComponents;
begin
  setlength(tmp.buttons, 2);
  setlength(tmp.lstcomponents, 2);
  SetLength(tmp.texts, 2);
  tmp.window.title := 'Подтверждение действия';
  with tmp.texts[tx] do
  begin
    title := 'Данные которые вы хотите удалить, будут безвозвратно утеряны';
    x := (WindowWidth - title.Length) div 2;
    y := (WindowHeight div 2) div 2;
  end;
  inc(tx);
  with tmp.texts[tx] do
  begin
    title := 'Вы точно хотите подтвердить данное действие?';
    x := (WindowWidth - title.Length) div 2;
    y := (WindowHeight div 2) div 2 + 1;
  end;
  inc(tx);
  with tmp.buttons[bn] do
  begin
    title := 'Отмена';
    x := (WindowWidth div 2 - title.Length - 2) div 2;
    y := WindowHeight div 2;
    text_color := LightRed;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'exit_button';
    index := bn;
    component_type := ComponentTypes.ButtonType;
  end;
  inc(i);
  inc(bn);
  with tmp.buttons[bn] do
  begin
    title := 'Подтвердить';
    x := (WindowWidth div 2 - title.Length - 2) div 2 + WindowWidth div 2;
    y := WindowHeight div 2;
    text_color := Green;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'action';
    index := bn;
    component_type := ComponentTypes.ButtonType;
  end;
  inc(i);
  inc(bn);
  Result := tmp;
end;

function CreateStudentsForm(account: account_rec): GuiComponents;
var
  i, bn, tb, free_space, busy_space, n: integer;
  tmp: GuiComponents;
begin
  n := 1;
  if account.admin = 1 then inc(n);
  SetLength(tmp.tables, 1);
  setlength(tmp.buttons, n);
  setlength(tmp.lstcomponents, 1 + n);
  tmp.window.title := 'Просмотр таблицы студентов';
  with tmp.tables[tb] do
  begin
    setlength(columns, 4);
    free_space := WindowWidth - 5 - 4;
    busy_space := trunc(free_space / 4);
    free_space := free_space - busy_space;
    columns[0] := CreateColumn('Фамилия', busy_space, AlignCenter);
    busy_space := trunc(free_space / 3);
    free_space := free_space - busy_space;
    columns[1] := CreateColumn('Имя', busy_space, AlignCenter);
    busy_space := ceil(free_space / 2);
    free_space := free_space - busy_space;
    columns[2] := CreateColumn('Отчество', busy_space, AlignCenter);
    columns[3] := CreateColumn('Стипендия', free_space, AlignCenter);
    
    if account.admin <> 1 then read_only := true;
    height := WindowHeight - 3 - 3;
    x := 3;
    y := 3;
    title := 'Студенты';
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'students_table';
    index := tb;
    component_type := ComponentTypes.TableType;
  end;
  inc(i);
  inc(tb);
  with tmp.buttons[bn] do
  begin
    title := 'Выйти';
    x := (WindowWidth div 2 - title.Length - 2) div 2;
    y := WindowHeight - 2;
    text_color := LightRed;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'exit_button';
    index := bn;
    component_type := ComponentTypes.ButtonType;
  end;
  inc(i);
  inc(bn);
  if account.admin = 1 then begin
    with tmp.buttons[bn] do
    begin
      title := 'Добавить нового студента';
      x := (WindowWidth div 2 - title.Length - 2) div 2 + WindowWidth div 2;
      y := WindowHeight - 2;
      text_color := Green;
    end;
    with tmp.lstcomponents[i] do
    begin
      name := 'add_student';
      index := bn;
      component_type := ComponentTypes.ButtonType;
    end;
    inc(i);
    inc(bn);
  end;
  Result := tmp;
end;

function CreateStudentForm(account: account_rec; is_add: boolean): GuiComponents;
var
  i, bn, tf, sl, n: integer;
  tmp: GuiComponents;
begin
  n := 1;
  if account.admin = 1 then inc(n);
  if not is_add then inc(n);
  SetLength(tmp.selects, 1);
  setlength(tmp.buttons, n);
  setlength(tmp.text_fields, 4);
  setlength(tmp.lstcomponents, n + 4 + 1);
  tmp.window.title := 'Замените название на своё действие';
  with tmp.text_fields[tf] do
  begin
    title := 'Фамилия';
    x := 2;
    y := 2;
    width := WindowWidth - 2;
    allow_alphabet := true;
    if account.admin <> 1 then read_only := true;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'familiya_field';
    index := tf;
    component_type := ComponentTypes.TextFieldType;
  end;
  inc(i);
  inc(tf);
  with tmp.text_fields[tf] do
  begin
    title := 'Имя';
    x := 2;
    y := 5;
    allow_alphabet := true;
    width := WindowWidth - 2;
    if account.admin <> 1 then read_only := true;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'imya_field';
    index := tf;
    component_type := ComponentTypes.TextFieldType;
  end;
  inc(i);
  inc(tf);
  with tmp.text_fields[tf] do
  begin
    title := 'Отчество';
    x := 2;
    y := 8;
    allow_alphabet := true;
    width := WindowWidth - 2;
    if account.admin <> 1 then read_only := true;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'otchestvo_field';
    index := tf;
    component_type := ComponentTypes.TextFieldType;
  end;
  inc(i);
  inc(tf);
  with tmp.text_fields[tf] do
  begin
    title := 'Стипендия';
    x := 2;
    y := 11;
    allow_numbers := true;
    width := WindowWidth - 2;
    if account.admin <> 1 then read_only := true;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'stipendia_field';
    index := tf;
    component_type := ComponentTypes.TextFieldType;
  end;
  inc(i);
  inc(tf);
  with tmp.selects[sl] do
  begin
    title := 'Считать стипендию автоматически?';
    x := 2;
    y := 14;
    width := WindowWidth - 2;
    setlength(items, 2);
    items[0] := 'Нет';
    items[1] := 'Да';
    if account.admin <> 1 then read_only := true;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'auto_calculate_field';
    index := sl;
    component_type := ComponentTypes.SelectType;
  end;
  inc(i);
  inc(sl);
  with tmp.buttons[bn] do
  begin
    title := 'Отмена';
    x := (WindowWidth div 3 - title.Length - 2) div 2;
    y := WindowHeight - 2;
    text_color := LightRed;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'exit_button';
    index := bn;
    component_type := ComponentTypes.ButtonType;
  end;
  inc(i);
  inc(bn);
  if account.admin = 1 then begin
    with tmp.buttons[bn] do
    begin
      title := 'Замените название на своё действие';
      x := (WindowWidth div 3 - title.Length - 2) div 2 + WindowWidth div 3;
      y := WindowHeight - 2;
      text_color := Green;
    end;
    with tmp.lstcomponents[i] do
    begin
      name := 'action';
      index := bn;
      component_type := ComponentTypes.ButtonType;
    end;
    inc(i);
    inc(bn);
  end;
  if not is_add then begin
    with tmp.buttons[bn] do
    begin
      title := 'Перейти к таблице оценок';
      x := (WindowWidth div 3 - title.Length - 2) div 2 + 2 * (WindowWidth div 3);
      y := WindowHeight - 2;
      text_color := LightBlue;
    end;
    with tmp.lstcomponents[i] do
    begin
      name := 'open_marks_table';
      index := bn;
      component_type := ComponentTypes.ButtonType;
    end;
    inc(i);
    inc(bn);
  end;
  Result := tmp;
end;

function CreateDisciplinesForm(): GuiComponents;
var
  i, bn, tb, free_space: integer;
  tmp: GuiComponents;
begin
  SetLength(tmp.tables, 1);
  setlength(tmp.buttons, 2);
  setlength(tmp.lstcomponents, 3);
  tmp.window.title := 'Просмотр зарегистрированных дисциплин';
  with tmp.tables[tb] do
  begin
    setlength(columns, 1);
    free_space := WindowWidth - 5 - 4;
    columns[0] := CreateColumn('Название дисциплины', free_space, AlignCenter);
    
    height := WindowHeight - 3 - 3;
    x := 3;
    y := 3;
    title := 'Дисциплины';
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'disciplines_table';
    index := tb;
    component_type := ComponentTypes.TableType;
  end;
  inc(i);
  inc(tb);
  with tmp.buttons[bn] do
  begin
    title := 'Выйти';
    x := (WindowWidth div 2 - title.Length - 2) div 2;
    y := WindowHeight - 2;
    text_color := LightRed;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'exit_button';
    index := bn;
    component_type := ComponentTypes.ButtonType;
  end;
  inc(i);
  inc(bn);
  with tmp.buttons[bn] do
  begin
    title := 'Добавить новую дисциплину';
    x := (WindowWidth div 2 - title.Length - 2) div 2 + WindowWidth div 2;
    y := WindowHeight - 2;
    text_color := Green;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'add_discipline';
    index := bn;
    component_type := ComponentTypes.ButtonType;
  end;
  inc(i);
  inc(bn);
  Result := tmp;
end;

function CreateDisciplineForm(): GuiComponents;
var
  i, bn, tf: integer;
  tmp: GuiComponents;
begin
  setlength(tmp.buttons, 2);
  setlength(tmp.text_fields, 1);
  setlength(tmp.lstcomponents, 3);
  tmp.window.title := 'Замените название на своё действие';
  with tmp.text_fields[tf] do
  begin
    title := 'Название дисциплины';
    x := 2;
    y := 2;
    width := WindowWidth - 2;
    allow_alphabet := true;
    allow_space := true;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'discipline_name_field';
    index := tf;
    component_type := ComponentTypes.TextFieldType;
  end;
  inc(i);
  inc(tf);
  with tmp.buttons[bn] do
  begin
    title := 'Отмена';
    x := (WindowWidth div 2 - title.Length - 2) div 2;
    y := WindowHeight - 2;
    text_color := LightRed;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'exit_button';
    index := bn;
    component_type := ComponentTypes.ButtonType;
  end;
  inc(i);
  inc(bn);
  with tmp.buttons[bn] do
  begin
    title := 'Замените название на своё действие';
    x := (WindowWidth div 2 - title.Length - 2) div 2 + WindowWidth div 2;
    y := WindowHeight - 2;
    text_color := Green;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'action';
    index := bn;
    component_type := ComponentTypes.ButtonType;
  end;
  inc(i);
  inc(bn);
  Result := tmp;
end;

function CreateBaseStipendiaForm(): GuiComponents;
var
  i, bn, tf: integer;
  tmp: GuiComponents;
begin
  setlength(tmp.buttons, 2);
  setlength(tmp.text_fields, 1);
  setlength(tmp.lstcomponents, 3);
  tmp.window.title := 'Изменение базовой стипендии';
  with tmp.text_fields[tf] do
  begin
    title := 'Базовая стипендия';
    x := 2;
    y := 2;
    width := WindowWidth - 2;
    allow_numbers := true;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'base_stipendia_field';
    index := tf;
    component_type := ComponentTypes.TextFieldType;
  end;
  inc(i);
  inc(tf);
  with tmp.buttons[bn] do
  begin
    title := 'Отмена';
    x := (WindowWidth div 2 - title.Length - 2) div 2;
    y := WindowHeight - 2;
    text_color := LightRed;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'exit_button';
    index := bn;
    component_type := ComponentTypes.ButtonType;
  end;
  inc(i);
  inc(bn);
  with tmp.buttons[bn] do
  begin
    title := 'Изменить базовую стипендию';
    x := (WindowWidth div 2 - title.Length - 2) div 2 + WindowWidth div 2;
    y := WindowHeight - 2;
    text_color := Green;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'action';
    index := bn;
    component_type := ComponentTypes.ButtonType;
  end;
  inc(i);
  inc(bn);
  Result := tmp;
end;

function CreateMarksForm(account: account_rec; is_denied_marks: boolean): GuiComponents;
var
  i, bn, tb, free_space, n: integer;
  tmp: GuiComponents;
begin
  n := 1;
  if not is_denied_marks then n := n + 1;
  if account.admin = 1 then n := n + 1;
  SetLength(tmp.tables, 1);
  setlength(tmp.buttons, n);
  setlength(tmp.lstcomponents, 1 + n);
  tmp.window.title := 'Замените какой тип оценок';
  with tmp.tables[tb] do
  begin
    setlength(columns, 2);
    free_space := WindowWidth - 3 - 4 - 7;
    columns[0] := CreateColumn('Название дисциплины', free_space, AlignCenter);
    columns[1] := CreateColumn('Оценка', 7, AlignCenter);
    
    if account.admin <> 1 then read_only := true;
    height := WindowHeight - 3 - 3;
    x := 3;
    y := 3;
    title := 'Оценки студента';
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'marks_table';
    index := tb;
    component_type := ComponentTypes.TableType;
  end;
  inc(i);
  inc(tb);
  with tmp.buttons[bn] do
  begin
    title := 'Выйти';
    x := (WindowWidth div 3 - title.Length - 2) div 2;
    y := WindowHeight - 2;
    text_color := LightRed;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'exit_button';
    index := bn;
    component_type := ComponentTypes.ButtonType;
  end;
  inc(i);
  inc(bn);
  if not is_denied_marks then begin
    with tmp.buttons[bn] do
    begin
      title := 'Посмотреть задолжности';
      x := (WindowWidth div 3 - title.Length - 2) div 2 + WindowWidth div 3;
      y := WindowHeight - 2;
      text_color := LightCyan;
    end;
    with tmp.lstcomponents[i] do
    begin
      name := 'open_denied_disciplines';
      index := bn;
      component_type := ComponentTypes.ButtonType;
    end;
    inc(i);
    inc(bn);
    if account.admin = 1 then begin
      with tmp.buttons[bn] do
      begin
        title := 'Добавить новую оценку';
        x := (WindowWidth div 3 - title.Length - 2) div 2 + 2 * (WindowWidth div 3);
        y := WindowHeight - 2;
        text_color := Green;
      end;
      with tmp.lstcomponents[i] do
      begin
        name := 'add_mark';
        index := bn;
        component_type := ComponentTypes.ButtonType;
      end;
    end;
    inc(i);
    inc(bn);
  end;
  Result := tmp;
end;

function CreateMarkForm(account: account_rec): GuiComponents;
var
  i, bn, sl, n: integer;
  tmp: GuiComponents;
begin
  n := 1;
  if account.admin = 1 then Inc(n);
  setlength(tmp.buttons, n);
  setlength(tmp.selects, 2);
  setlength(tmp.lstcomponents, 2 + n);
  tmp.window.title := 'Замените на своё действие с оценкой';
  with tmp.selects[sl] do
  begin
    title := 'Название дисциплины';
    x := 2;
    y := 2;
    width := WindowWidth - 2;
    
    if account.admin <> 1 then read_only := true;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'discipline_field';
    index := sl;
    component_type := ComponentTypes.SelectType;
  end;
  inc(i);
  inc(sl);
  with tmp.selects[sl] do
  begin
    title := 'Выбор оценки';
    x := 2;
    y := 5;
    width := WindowWidth - 2;
    setlength(items, 5);
    items[0] := '1';
    items[1] := '2';
    items[2] := '3';
    items[3] := '4';
    items[4] := '5';
    if account.admin <> 1 then read_only := true;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'mark_field';
    index := sl;
    component_type := ComponentTypes.SelectType;
  end;
  inc(i);
  inc(sl);
  with tmp.buttons[bn] do
  begin
    title := 'Отмена';
    x := (WindowWidth div 2 - title.Length - 2) div 2;
    y := WindowHeight - 2;
    text_color := LightRed;
  end;
  with tmp.lstcomponents[i] do
  begin
    name := 'exit_button';
    index := bn;
    component_type := ComponentTypes.ButtonType;
  end;
  inc(i);
  inc(bn);
  if account.admin = 1 then begin
    with tmp.buttons[bn] do
    begin
      title := 'Замените на своё действие с оценкой';
      x := (WindowWidth div 3 - title.Length - 2) div 2 + 2 * (WindowWidth div 3);
      y := WindowHeight - 2;
      text_color := Green;
    end;
    with tmp.lstcomponents[i] do
    begin
      name := 'action';
      index := bn;
      component_type := ComponentTypes.ButtonType;
    end;
    inc(i);
    inc(bn);
  end;
  Result := tmp;
end;

begin

end. 