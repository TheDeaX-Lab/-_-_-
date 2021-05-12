uses crt, PseudoGraphic, Forms, Authentication, StudentsModule, DisciplinesModule;

const
  AccountsFileName = 'accounts.dat';
  StudentsFileName = 'students.dat';
  DisciplinesFileName = 'disciplines.dat';
  BaseStipendiaFileName = 'basestipendia.dat';

var
  {Окружение программы}
  {Хранимые формы}
  test_form,
  {Стартовое меню}
  start_menu,
  {Меню авторизации}
  auth_menu,
  {Главное меню}
  main_menu,
  {Таблицы аккаунтов и форма добавления, редактирования или просмотра аккаунта,
  доступна исключительно для администратора}
  accounts_form, account_form,
  {Таблица существующих дисциплин и форма добавления, редактирования или просмотра дисциплин,
  добавление, удаление и редактирование доступно только администратору}
  disciplines_form, discipline_form,
  {Таблица студентов и форма добавления, редактирования или просмотра дисциплин,
  добавление, удаление и редактирование доступно только администратору}
  students_form, student_form,
  {Таблица в виде связки оценок и дисциплин, также форма добавления, редактирования или просмотра дисциплин,
  добавление, удаление и редактирование доступно только администратору}
  denied_marks_form, marks_form, mark_form,
  {Форма изменения базовой стипендии}
  stipendia_form,
  {Простой диалог подтверждения}
  apply_dialog: GuiComponents;
  {Текущий рабочий аккаунт для пользователя}
  current_account: account_rec;
  {Временная переменная для добавляемого аккаунта}
  current_add_account: account_rec;
  {Временный индекс изменяемого аккаунта}
  current_edit_account_index: integer := -1;
  {Временный индекс удаляемого аккаунта}
  current_delete_account_index: integer := -1;
  {Временная переменная для добавляемого студента}
  current_add_student: student_rec;
  {Временный индекс изменяемого студента}
  current_edit_student_index: integer := -1;
  {Временный индекс удаляемого студента}
  current_delete_student_index: integer := -1;
  {Временная переменная для добавляемой дисциплины}
  current_add_discipline: discipline_rec;
  {Временный индекс изменяемой дисциплины}
  current_edit_discipline_index: integer := -1;
  {Временный индекс удаляемой дисциплины}
  current_delete_discipline_index: integer := -1;
  {Временная переменная для хранения дисциплин по которым не выставлены оценки}
  not_mark_disciplines: array of string;
  {Временная переменная изменяемой оценки}
  current_mark_edit_index: integer := -1;

procedure OnExitAccountsTable;
begin
  accounts_form.stopped := true;
  FullRender(main_menu);
end;

procedure OnCancelAccountFormAdd;
var
  clr_acc: account_rec;
begin
  current_add_account := clr_acc;
  account_form.stopped := true;
  FullRender(accounts_form);
end;

procedure OnApplyAccountFormAdd;
var
  clr_acc: account_rec;
  error_login, error_password: boolean;
  err_text: TextComponent;
begin
  current_add_account.login := account_form.text_fields[GetIndexByNameFromAssociationList(account_form.lstcomponents, 'login_field')].text_value;
  if current_add_account.login.Length = 0 then error_login := true;
  current_add_account.password := account_form.text_fields[GetIndexByNameFromAssociationList(account_form.lstcomponents, 'password_field')].text_value;
  if current_add_account.password.Length = 0 then error_password := true;
  current_add_account.admin := account_form.selects[GetIndexByNameFromAssociationList(account_form.lstcomponents, 'admin_field')].selected_index;
  if not (error_login or error_password or IsDuplicateAccount(current_add_account, -1)) then begin
    AddAccount(current_add_account);
    SaveAccountsFile(AccountsFileName);
    current_add_account := clr_acc;
    account_form.stopped := true;
    inc(accounts_form.tables[GetIndexByNameFromAssociationList(accounts_form.lstcomponents, 'accounts_table')].count_rows);
    FullRender(accounts_form);
  end else begin
    with err_text do
    begin
      if error_login then
        title := 'Введите логин'
      else if error_password then
        title := 'Введите пароль'
      else
        title := 'Данный логин уже существует!';
      text_color := LightRed;
      x := (WindowWidth - title.Length) div 2;
      y := WindowHeight - 5;
    end;
    RenderTextComponent(err_text);
    ReadKey;
    ClsSquare(err_text.x, err_text.y, err_text.title.Length, 1);
  end;
end;

procedure OnOpenAccountFormAdd;
{procedure OnCancelAccountFormAdd;
var
  clr_acc: account_rec;
begin
  current_add_account := clr_acc;
  account_form.stopped := true;
  FullRender(accounts_form);
end;}
begin
  account_form := CreateAccountForm();
  account_form.window.title := 'Добавление аккаунта';
  with account_form.buttons[GetIndexByNameFromAssociationList(account_form.lstcomponents, 'action')] do
  begin
    title := 'Добавить аккаунт';
    x := (WindowWidth div 2 - title.Length - 2) div 2 + WindowWidth div 2;
    onclick := OnApplyAccountFormAdd;
  end;
  account_form.buttons[GetIndexByNameFromAssociationList(account_form.lstcomponents, 'exit_button')].onclick := OnCancelAccountFormAdd;
  FullRender(account_form);
  EventLoop(account_form);
end;

procedure OnCancelAccountFormEdit;
begin
  current_edit_account_index := -1;
  account_form.stopped := true;
  FullRender(accounts_form);
end;

procedure OnApplyAccountFormEdit;
var
  tmp: account_rec;
  error_login, error_password: boolean;
  err_text: TextComponent;
begin
  tmp.login := account_form.text_fields[GetIndexByNameFromAssociationList(account_form.lstcomponents, 'login_field')].text_value;
  if tmp.login.Length = 0 then error_login := true;
  tmp.password := account_form.text_fields[GetIndexByNameFromAssociationList(account_form.lstcomponents, 'password_field')].text_value;
  if tmp.password.Length = 0 then error_password := true;
  tmp.admin := account_form.selects[GetIndexByNameFromAssociationList(account_form.lstcomponents, 'admin_field')].selected_index;
  if not (error_login or error_password or IsDuplicateAccount(tmp, current_edit_account_index)) then begin
    accounts[current_edit_account_index] := tmp;
    SaveAccountsFile(AccountsFileName);
    current_edit_account_index := -1;
    account_form.stopped := true;
    FullRender(accounts_form);
  end else begin
    with err_text do
    begin
      if error_login then
        title := 'Введите логин'
      else if error_password then
        title := 'Введите пароль'
      else
        title := 'Данный логин уже существует!';
      text_color := LightRed;
      x := (WindowWidth - title.Length) div 2;
      y := WindowHeight - 5;
    end;
    RenderTextComponent(err_text);
    ReadKey;
    ClsSquare(err_text.x, err_text.y, err_text.title.Length, 1);
  end;
end;

procedure OnOpenAccountFormEdit(i: integer);
begin
  account_form := CreateAccountForm();
  current_edit_account_index := i;
  account_form.text_fields[GetIndexByNameFromAssociationList(account_form.lstcomponents, 'login_field')].text_value := accounts[current_edit_account_index].login;
  account_form.text_fields[GetIndexByNameFromAssociationList(account_form.lstcomponents, 'password_field')].text_value := accounts[current_edit_account_index].password;
  account_form.selects[GetIndexByNameFromAssociationList(account_form.lstcomponents, 'admin_field')].selected_index := accounts[current_edit_account_index].admin;
  account_form.window.title := 'Изменение аккаунта';
  with account_form.buttons[GetIndexByNameFromAssociationList(account_form.lstcomponents, 'action')] do
  begin
    onclick := OnApplyAccountFormEdit;
    title := 'Изменить аккаунт';
    x := (WindowWidth div 2 - title.Length - 2) div 2 + WindowWidth div 2;
  end;
  account_form.buttons[GetIndexByNameFromAssociationList(account_form.lstcomponents, 'exit_button')].onclick := OnCancelAccountFormEdit;
  FullRender(account_form);
  EventLoop(account_form);
end;

procedure OnCancelAccountFormDelete;
begin
  current_delete_account_index := -1;
  apply_dialog.stopped := true;
  FullRender(accounts_form);
end;

procedure OnApplyAccountFormDelete;
begin
  RemoveAccount(accounts[current_delete_account_index]);
  SaveAccountsFile(AccountsFileName);
  current_delete_account_index := -1;
  apply_dialog.stopped := true;
  Dec(accounts_form.tables[GetIndexByNameFromAssociationList(accounts_form.lstcomponents, 'accounts_table')].count_rows);
  with accounts_form.tables[GetIndexByNameFromAssociationList(accounts_form.lstcomponents, 'accounts_table')] do
  begin
    if cursor > 0 then dec(cursor)
    else if current_page > 0 then current_page := max(current_page - rows_per_page, 0);
  end;
  FullRender(accounts_form);
end;

procedure OnOpenAccountFormDelete(i: integer);
begin
  apply_dialog := CreateApplyForm();
  apply_dialog.buttons[GetIndexByNameFromAssociationList(apply_dialog.lstcomponents, 'exit_button')].onclick := OnCancelAccountFormDelete;
  apply_dialog.buttons[GetIndexByNameFromAssociationList(apply_dialog.lstcomponents, 'action')].onclick := OnApplyAccountFormDelete;
  current_delete_account_index := i;
  FullRender(apply_dialog);
  EventLoop(apply_dialog);
end;

procedure OnOpenAccountsTable;
begin
  accounts_form := CreateAccountsForm();
  accounts_form.buttons[GetIndexByNameFromAssociationList(accounts_form.lstcomponents, 'exit_button')].onclick := OnExitAccountsTable;
  accounts_form.buttons[GetIndexByNameFromAssociationList(accounts_form.lstcomponents, 'add_account')].onclick := OnOpenAccountFormAdd;
  with accounts_form.tables[GetIndexByNameFromAssociationList(accounts_form.lstcomponents, 'accounts_table')] do
  begin
    get_row := GetAccountRow;
    count_rows := accounts.Length;
    onclick_row := OnOpenAccountFormEdit;
    ondelete_row := OnOpenAccountFormDelete;
  end;
  FullRender(accounts_form);
  EventLoop(accounts_form);
end;

{Процедура отвечающая за логику кнопки выхода из меню}
procedure OnExitMenu;
var
  {Пустая запись аккаунта}
  account: account_rec;
begin
  {Останавливаем цикл захвата клавиш для формы меню}
  main_menu.stopped := true;
  {Счищаем окружение аккаунта на пустой аккаунт}
  current_account := account;
  {Отображаем форму авторизации}
  FullRender(auth_menu);
  {После того как процедура сработала, помним о стеке:
  Меню было вызвано формой авторизации}
end;

procedure OnExitStudentsTable;
begin
  students_form.stopped := true;
  FullRender(main_menu);
end;

procedure OnExitStudentFormAdd;
begin
  student_form.stopped := true;
  FullRender(students_form);
end;

procedure OnApplyStudentFormAdd;
var
  clr_stud: student_rec;
  err_text: TextComponent;
  error_stipendia, error_familiya, error_imya, error_otchestvo: boolean;
begin
  current_add_student.familiya := student_form.text_fields[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'familiya_field')].text_value;
  if current_add_student.familiya.Length = 0 then error_familiya := true;
  current_add_student.imya := student_form.text_fields[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'imya_field')].text_value;
  if current_add_student.imya.Length = 0 then error_imya := true;
  current_add_student.otchestvo := student_form.text_fields[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'otchestvo_field')].text_value;
  if current_add_student.otchestvo.Length = 0 then error_otchestvo := true;
  current_add_student.auto_calculate := student_form.selects[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'auto_calculate_field')].selected_index;
  try
    current_add_student.stipendia := StrToInt(student_form.text_fields[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'stipendia_field')].text_value);
  except
    error_stipendia := true;
  end;
  if current_add_student.auto_calculate = 1 then begin
    error_stipendia := false;
  end;
  if not (error_stipendia or error_familiya or error_imya or error_otchestvo or IsDuplicateStudent(current_add_student, -1)) then begin
    if current_add_student.auto_calculate = 1 then
      CalculateStipendiaForStudent(current_add_student);
    AddStudent(current_add_student);
    SaveStudentsToFile(StudentsFileName);
    inc(students_form.tables[GetIndexByNameFromAssociationList(students_form.lstcomponents, 'students_table')].count_rows);
    current_add_student := clr_stud;
    student_form.stopped := true;
    FullRender(students_form);
  end else begin
    with err_text do
    begin
      if error_familiya then
        title := 'Введите фамилию студента'
      else if error_imya then
        title := 'Введите имя студента'
      else if error_otchestvo then
        title := 'Введите отчество студента'
      else if error_stipendia then
        title := 'Неправильно записана стипендия'
      else
        title := 'Данный студент с ФИО уже существует';
      text_color := LightRed;
      x := (WindowWidth - title.Length) div 2;
      y := WindowHeight - 5;
    end;
    RenderTextComponent(err_text);
    ReadKey;
    ClsSquare(err_text.x, err_text.y, err_text.title.Length, 1);
  end;
end;

procedure OnOpenStudentFormAdd;
begin
  student_form := CreateStudentForm(current_account, true);
  student_form.window.title := 'Добавление студента';
  with student_form.buttons[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'exit_button')] do
  begin
    x := (WindowWidth div 2 - title.Length - 2) div 2;
    onclick := OnExitStudentFormAdd;
  end;
  if current_account.admin = 1 then begin
    with student_form.buttons[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'action')] do
    begin
      title := 'Добавить студента';
      x := (WindowWidth div 2 - title.Length - 2) div 2 + WindowWidth div 2;
      onclick := OnApplyStudentFormAdd;
    end;
  end;
  
  FullRender(student_form);
  EventLoop(student_form);
end;

procedure OnExitStudentFormEdit;
begin
  if students[current_edit_student_index].auto_calculate = 1 then
    CalculateStipendiaForStudent(students[current_edit_student_index]);
  SaveStudentsToFile(StudentsFileName);
  student_form.stopped := true;
  FullRender(students_form);
end;

procedure OnApplyStudentFormEdit;
var
  tmp: student_rec;
  err_text: TextComponent;
  error_stipendia, error_familiya, error_imya, error_otchestvo: boolean;
begin
  tmp.familiya := student_form.text_fields[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'familiya_field')].text_value;
  if tmp.familiya.Length = 0 then error_familiya := true;
  tmp.imya := student_form.text_fields[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'imya_field')].text_value;
  if tmp.imya.Length = 0 then error_imya := true;
  tmp.otchestvo := student_form.text_fields[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'otchestvo_field')].text_value;
  if tmp.otchestvo.Length = 0 then error_otchestvo := true;
  tmp.auto_calculate := student_form.selects[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'auto_calculate_field')].selected_index;
  try
    current_add_student.stipendia := StrToInt(student_form.text_fields[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'stipendia_field')].text_value);
  except
    error_stipendia := true;
  end;
  if current_add_student.auto_calculate = 1 then begin
    error_stipendia := false;
  end;
  if not (error_stipendia or error_familiya or error_imya or error_otchestvo or IsDuplicateStudent(tmp, current_edit_student_index)) then begin
    students[current_edit_student_index].familiya := tmp.familiya;
    students[current_edit_student_index].imya := tmp.imya;
    students[current_edit_student_index].otchestvo := tmp.otchestvo;
    students[current_edit_student_index].auto_calculate := tmp.auto_calculate;
    students[current_edit_student_index].stipendia := tmp.stipendia;
    if tmp.auto_calculate = 1 then
      CalculateStipendiaForStudent(students[current_edit_student_index]);
    students[current_edit_student_index].familiya := tmp.familiya;
    SaveStudentsToFile(StudentsFileName);
    current_edit_student_index := -1;
    student_form.stopped := true;
    FullRender(students_form);
  end else begin
    with err_text do
    begin
      if error_familiya then
        title := 'Введите фамилию студента'
      else if error_imya then
        title := 'Введите имя студента'
      else if error_otchestvo then
        title := 'Введите отчество студента'
      else if error_stipendia then
        title := 'Неправильно записана стипендия'
      else
        title := 'Данный студент с ФИО уже существует';
      text_color := LightRed;
      x := (WindowWidth - title.Length) div 2;
      y := WindowHeight - 5;
    end;
    RenderTextComponent(err_text);
    ReadKey;
    ClsSquare(err_text.x, err_text.y, err_text.title.Length, 1);
  end;
end;

procedure OnExitDeniedMarksTable;
begin
  denied_marks_form.stopped := true;
  FullRender(marks_form);
end;

procedure NullProcedure(i: integer);
begin
  
end;

procedure OnOpenDeniedMarksTable;
var
  i, j, n: integer;
begin
  denied_marks_form := CreateMarksForm(current_account, true);
  SetLength(denied_disciplines_id, 0);
  denied_marks_form.window.title := 'Просмотр задолжностей';
  denied_marks_form.buttons[GetIndexByNameFromAssociationList(denied_marks_form.lstcomponents, 'exit_button')].onclick := OnExitDeniedMarksTable;
  for i := 0 to High(disciplines) do
  begin
    for j := 0 to High(students[current_edit_student_index].marks) do
    begin
      if (students[current_edit_student_index].marks[j].discipline_id = disciplines[i].id) then begin
        break;
      end;
    end;
    if (High(students[current_edit_student_index].marks) = -1)
       or ((students[current_edit_student_index].marks[j].discipline_id = disciplines[i].id) and (students[current_edit_student_index].marks[j].mark < 3))
       or (students[current_edit_student_index].marks[j].discipline_id <> disciplines[i].id)
       then
    begin
      n := high(denied_disciplines_id) + 1;
      SetLength(denied_disciplines_id, n + 1);
      denied_disciplines_id[n] := disciplines[i].id;
      
    end;
  end;
  with denied_marks_form.tables[GetIndexByNameFromAssociationList(denied_marks_form.lstcomponents, 'marks_table')] do
  begin
    count_rows := high(denied_disciplines_id) + 1;
    get_row := GetRowMarkDenied;
    onclick_row := NullProcedure;
    ondelete_row := NullProcedure;
  end;
  FullRender(denied_marks_form);
  EventLoop(denied_marks_form);
end;

procedure OnExitMarksTable;
begin
  marks_form.stopped := true;
  FullRender(student_form);
end;

procedure OnExitMarkFormAdd;
begin
  mark_form.stopped := true;
  FullRender(marks_form);
end;

procedure OnApplyMarkFormAdd;
var
  tmp: mark_rec;
  i, selected_discipline: integer;
begin
  selected_discipline := mark_form.selects[GetIndexByNameFromAssociationList(mark_form.lstcomponents, 'discipline_field')].selected_index;
  for i := 0 to High(disciplines) do
  begin
    if disciplines[i].name = not_mark_disciplines[selected_discipline] then begin
      tmp.discipline_id := disciplines[i].id
    end;
  end;
  tmp.mark := mark_form.selects[GetIndexByNameFromAssociationList(mark_form.lstcomponents, 'mark_field')].selected_index + 1;
  AddMarkToStudent(students[current_edit_student_index], tmp);
  if current_student.auto_calculate = 1 then
    CalculateStipendiaForStudent(students[current_edit_student_index]);
  SaveStudentsToFile(StudentsFileName);
  current_student := students[current_edit_student_index];
  mark_form.stopped := true;
  inc(marks_form.tables[GetIndexByNameFromAssociationList(marks_form.lstcomponents, 'marks_table')].count_rows);
  FullRender(marks_form);
end;

procedure OnOpenMarkFormAdd;
var
  i, j, n: integer;
  err_text: TextComponent;
begin
  SetLength(not_mark_disciplines, 0);
  for i := 0 to high(disciplines) do
  begin
    for j := 0 to high(current_student.marks) do
    begin
      if current_student.marks[j].discipline_id = disciplines[i].id then break;
    end;
    if (high(current_student.marks) = -1) or (current_student.marks[j].discipline_id <> disciplines[i].id) then begin
      n := High(not_mark_disciplines) + 1;
      SetLength(not_mark_disciplines, n + 1);
      not_mark_disciplines[n] := disciplines[i].name;
    end;
  end;
  if high(not_mark_disciplines) > -1 then begin
    mark_form := CreateMarkForm(current_account);
    mark_form.window.title := 'Добавление оценки';
    mark_form.selects[GetIndexByNameFromAssociationList(mark_form.lstcomponents, 'discipline_field')].items := not_mark_disciplines;
    mark_form.buttons[GetIndexByNameFromAssociationList(mark_form.lstcomponents, 'exit_button')].onclick := OnExitMarkFormAdd;
    with mark_form.buttons[GetIndexByNameFromAssociationList(mark_form.lstcomponents, 'action')] do
    begin
      onclick := OnApplyMarkFormAdd;
      title := 'Добавить оценку';
      x := (WindowWidth div 2 - title.Length - 2) div 2 + WindowWidth div 2;
    end;
    FullRender(mark_form);
    EventLoop(mark_form);
  end else begin
    with err_text do
    begin
      title := 'Нет дисциплин по которым не выставлены оценки';
      text_color := LightRed;
      x := (WindowWidth - title.Length) div 2;
      y := WindowHeight - 1;
    end;
    RenderTextComponent(err_text);
    ReadKey;
    ClsSquare(err_text.x, err_text.y, err_text.title.Length, 1);
  end;
end;

procedure OnExitMarkFormEdit;
begin
  mark_form.stopped := true;
  FullRender(marks_form);
end;

procedure OnApplyMarkFormEdit;
var
  i, selected_discipline: integer;
begin
  for i := 0 to High(disciplines) do
  begin
    if disciplines[i].name = not_mark_disciplines[selected_discipline] then begin
      students[current_edit_student_index].marks[current_mark_edit_index].discipline_id := disciplines[i].id;
    end;
  end;
  students[current_edit_student_index].marks[current_mark_edit_index].mark := mark_form.selects[GetIndexByNameFromAssociationList(mark_form.lstcomponents, 'mark_field')].selected_index + 1;
  if current_student.auto_calculate = 1 then
    CalculateStipendiaForStudent(students[current_edit_student_index]);
  SaveStudentsToFile(StudentsFileName);
  current_student := students[current_edit_student_index];
  mark_form.stopped := true;
  FullRender(marks_form);
end;

procedure OnOpenMarkFormEdit(i: integer);
var
  j, k, n: integer;
begin
  SetLength(not_mark_disciplines, 0);
  current_mark_edit_index := i;
  mark_form := CreateMarkForm(current_account);
  mark_form.window.title := 'Изменение оценки';
  mark_form.selects[GetIndexByNameFromAssociationList(mark_form.lstcomponents, 'mark_field')].selected_index := current_student.marks[current_mark_edit_index].mark - 1;
  for k := 0 to high(disciplines) do
  begin
    for j := 0 to high(current_student.marks) do
    begin
      if current_student.marks[j].discipline_id = disciplines[k].id then break;
    end;
    if (high(current_student.marks) = -1) or (current_student.marks[j].discipline_id <> disciplines[k].id) or (j = i) then begin
      n := High(not_mark_disciplines) + 1;
      SetLength(not_mark_disciplines, n + 1);
      not_mark_disciplines[n] := disciplines[i].name;
      if j = i then
        mark_form.selects[GetIndexByNameFromAssociationList(mark_form.lstcomponents, 'discipline_field')].selected_index := n;
    end;
  end;
  mark_form.selects[GetIndexByNameFromAssociationList(mark_form.lstcomponents, 'discipline_field')].items := not_mark_disciplines;
  mark_form.buttons[GetIndexByNameFromAssociationList(mark_form.lstcomponents, 'exit_button')].onclick := OnExitMarkFormAdd;
  if current_account.admin = 1 then begin
    with mark_form.buttons[GetIndexByNameFromAssociationList(mark_form.lstcomponents, 'action')] do
    begin
      onclick := OnApplyMarkFormEdit;
      title := 'Изменить оценку';
      x := (WindowWidth div 2 - title.Length - 2) div 2 + WindowWidth div 2
    end;
  end;
  FullRender(mark_form);
  EventLoop(mark_form);
end;

procedure OnExitMarkFormDelete;
begin
  apply_dialog.stopped := true;
  FullRender(marks_form);
end;

procedure OnApplyMarkFormDelete;
begin
  DeleteMarkForStudent(students[current_edit_student_index], students[current_edit_student_index].marks[current_mark_edit_index]);
  if students[current_edit_student_index].auto_calculate = 1 then
    CalculateStipendiaForStudent(students[current_edit_student_index]);
  SaveStudentsToFile(StudentsFileName);
  with marks_form.tables[GetIndexByNameFromAssociationList(marks_form.lstcomponents, 'marks_table')] do
  begin
    dec(count_rows);
    if cursor > 0 then dec(cursor)
    else if current_page > 0 then current_page := max(current_page - rows_per_page, 0);
  end;
  apply_dialog.stopped := true;
  FullRender(marks_form);
end;

procedure OnOpenMarkFormDelete(i: integer);
begin
  current_mark_edit_index := i;
  apply_dialog := CreateApplyForm();
  apply_dialog.buttons[GetIndexByNameFromAssociationList(apply_dialog.lstcomponents, 'exit_button')].onclick := OnExitMarkFormDelete;
  apply_dialog.buttons[GetIndexByNameFromAssociationList(apply_dialog.lstcomponents, 'action')].onclick := OnApplyMarkFormDelete;
  current_delete_account_index := i;
  FullRender(apply_dialog);
  EventLoop(apply_dialog);
end;

procedure OnOpenMarksTable;
begin
  marks_form := CreateMarksForm(current_account, false);
  marks_form.window.title := 'Просмотр выставленных оценок';
  if current_account.admin = 1 then
    marks_form.buttons[GetIndexByNameFromAssociationList(marks_form.lstcomponents, 'add_mark')].onclick := OnOpenMarkFormAdd;
  marks_form.buttons[GetIndexByNameFromAssociationList(marks_form.lstcomponents, 'open_denied_disciplines')].onclick := OnOpenDeniedMarksTable;
  marks_form.buttons[GetIndexByNameFromAssociationList(marks_form.lstcomponents, 'exit_button')].onclick := OnExitMarksTable;
  with marks_form.tables[GetIndexByNameFromAssociationList(marks_form.lstcomponents, 'marks_table')] do
  begin
    count_rows := high(current_student.marks) + 1;
    get_row := GetRowMark;
    onclick_row := OnOpenMarkFormEdit;
    ondelete_row := OnOpenMarkFormDelete;
  end;
  FullRender(marks_form);
  EventLoop(marks_form);
end;

procedure OnOpenStudentFormEdit(i: integer);
begin
  current_edit_student_index := i;
  current_student := students[current_edit_student_index];
  student_form := CreateStudentForm(current_account);
  if current_account.admin = 1 then
    student_form.window.title := 'Изменение студента'
  else
    student_form.window.title := 'Просмотр студента';
  student_form.buttons[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'exit_button')].onclick := OnExitStudentFormEdit;
  if current_account.admin = 1 then
    with student_form.buttons[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'action')] do
    begin
      onclick := OnApplyStudentFormEdit;
      title := 'Изменить студента';
      x := (WindowWidth div 3 - title.Length - 2) div 2 + WindowWidth div 3;
    end;
  student_form.buttons[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'open_marks_table')].onclick := OnOpenMarksTable;
  student_form.text_fields[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'familiya_field')].text_value := students[i].familiya;
  student_form.text_fields[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'imya_field')].text_value := students[i].imya;
  student_form.text_fields[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'otchestvo_field')].text_value := students[i].otchestvo;
  student_form.text_fields[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'stipendia_field')].text_value := IntToStr(students[i].stipendia);
  student_form.selects[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'auto_calculate_field')].selected_index := students[i].auto_calculate;
  FullRender(student_form);
  EventLoop(student_form);
end;

procedure OnCancelStudentFormDelete;
begin
  apply_dialog.stopped := true;
  FullRender(students_form);
end;

procedure OnApplyStudentFormDelete;
begin
  DeleteStudent(students[current_delete_student_index]);
  SaveStudentsToFile(StudentsFileName);
  current_delete_student_index := -1;
  apply_dialog.stopped := true;
  Dec(students_form.tables[GetIndexByNameFromAssociationList(students_form.lstcomponents, 'students_table')].count_rows);
  with students_form.tables[GetIndexByNameFromAssociationList(students_form.lstcomponents, 'students_table')] do
  begin
    if cursor > 0 then dec(cursor)
    else if current_page > 0 then current_page := max(current_page - rows_per_page, 0);
  end;
  FullRender(students_form);
end;

procedure OnOpenStudentFormDelete(i: integer);
begin
  apply_dialog := CreateApplyForm();
  apply_dialog.buttons[GetIndexByNameFromAssociationList(apply_dialog.lstcomponents, 'exit_button')].onclick := OnCancelStudentFormDelete;
  apply_dialog.buttons[GetIndexByNameFromAssociationList(apply_dialog.lstcomponents, 'action')].onclick := OnApplyStudentFormDelete;
  current_delete_student_index := i;
  FullRender(apply_dialog);
  EventLoop(apply_dialog);
end;

procedure OnOpenStudentsTable;
begin
  students_form := CreateStudentsForm(current_account);
  students_form.buttons[GetIndexByNameFromAssociationList(students_form.lstcomponents, 'exit_button')].onclick := OnExitStudentsTable;
  if current_account.admin = 1 then
    students_form.buttons[GetIndexByNameFromAssociationList(students_form.lstcomponents, 'add_student')].onclick := OnOpenStudentFormAdd;
  with students_form do
  begin
    with tables[GetIndexByNameFromAssociationList(students_form.lstcomponents, 'students_table')] do
    begin
      get_row := GetRowStudent;
      try
        count_rows := students.Length;
      except
        count_rows := 0;
      end;
      onclick_row := OnOpenStudentFormEdit;
      if current_account.admin = 1 then
        ondelete_row := OnOpenStudentFormDelete;
    end;
  end;
  FullRender(students_form);
  EventLoop(students_form);
end;

procedure OnExitDisciplinesTable;
begin
  disciplines_form.stopped := true;
  FullRender(main_menu);
end;

procedure OnExitDisciplineFormAdd;
begin
  discipline_form.stopped := true;
  FullRender(disciplines_form);
end;

procedure OnApplyDisciplineFormAdd;
var
  clr_disp: discipline_rec;
  err_text: TextComponent;
  error_discipline_name: boolean;
  i: integer;
begin
  current_add_discipline.name := discipline_form.text_fields[GetIndexByNameFromAssociationList(discipline_form.lstcomponents, 'discipline_name_field')].text_value;
  if current_add_discipline.name.Length = 0 then error_discipline_name := true;
  if not (error_discipline_name or IsDuplicateDiscipline(current_add_discipline, -1)) then begin
    AddDiscipline(current_add_discipline);
    SaveDisciplinesToFile(DisciplinesFileName);
    for i := 0 to high(students) do
    begin
      if students[i].auto_calculate = 1 then
        CalculateStipendiaForStudent(students[i]);
    end;
    SaveStudentsToFile(StudentsFileName);
    inc(disciplines_form.tables[GetIndexByNameFromAssociationList(disciplines_form.lstcomponents, 'disciplines_table')].count_rows);
    current_add_discipline := clr_disp;
    discipline_form.stopped := true;
    FullRender(disciplines_form);
  end else begin
    with err_text do
    begin
      if error_discipline_name then
        title := 'Введите название дисциплины'
      else
        title := 'Данная дисциплина уже существует';
      text_color := LightRed;
      x := (WindowWidth - title.Length) div 2;
      y := WindowHeight - 5;
    end;
    RenderTextComponent(err_text);
    ReadKey;
    ClsSquare(err_text.x, err_text.y, err_text.title.Length, 1);
  end;
end;

procedure OnOpenDisciplineFormAdd;
begin
  discipline_form := CreateDisciplineForm();
  discipline_form.window.title := 'Добавление дисциплины';
  discipline_form.buttons[GetIndexByNameFromAssociationList(discipline_form.lstcomponents, 'exit_button')].onclick := OnExitDisciplineFormAdd;
  with discipline_form.buttons[GetIndexByNameFromAssociationList(discipline_form.lstcomponents, 'action')] do
  begin
    onclick := OnApplyDisciplineFormAdd;
    title := 'Добавить дисциплину';
    x := (WindowWidth div 2 - title.Length - 2) div 2 + WindowWidth div 2;
  end;
  FullRender(discipline_form);
  EventLoop(discipline_form);
end;

procedure OnCancelDisciplineFormDelete;
begin
  current_delete_discipline_index := -1;
  apply_dialog.stopped := true;
  FullRender(disciplines_form);
end;

procedure OnApplyDisciplineFormDelete;
var
  i: integer;
  m_tmp: mark_rec;
begin
  m_tmp.discipline_id := disciplines[current_delete_discipline_index].id;
  DeleteDiscipline(disciplines[current_delete_discipline_index]);
  for i := 0 to high(students) do
  begin
    DeleteMarkForStudent(students[i], m_tmp);
    if students[i].auto_calculate = 1 then
      CalculateStipendiaForStudent(students[i]);
  end;
  SaveStudentsToFile(StudentsFileName);
  SaveDisciplinesToFile(DisciplinesFileName);
  current_delete_discipline_index := -1;
  with disciplines_form.tables[GetIndexByNameFromAssociationList(disciplines_form.lstcomponents, 'disciplines_table')] do
  begin
    Dec(count_rows);
    if cursor > 0 then dec(cursor)
    else if current_page > 0 then current_page := max(current_page - rows_per_page, 0);
  end;
  apply_dialog.stopped := true;
  FullRender(disciplines_form);
end;

procedure OnOpenDisciplineFormDelete(i: integer);
begin
  apply_dialog := CreateApplyForm();
  apply_dialog.buttons[GetIndexByNameFromAssociationList(apply_dialog.lstcomponents, 'exit_button')].onclick := OnCancelDisciplineFormDelete;
  apply_dialog.buttons[GetIndexByNameFromAssociationList(apply_dialog.lstcomponents, 'action')].onclick := OnApplyDisciplineFormDelete;
  current_delete_discipline_index := i;
  FullRender(apply_dialog);
  EventLoop(apply_dialog);
end;

procedure OnExitDisciplineFormEdit;
begin
  current_edit_discipline_index := -1;
  discipline_form.stopped := true;
  FullRender(disciplines_form);
end;

procedure OnApplyDisciplineFormEdit;
var
  tmp: discipline_rec;
  err_text: TextComponent;
  error_discipline_name: boolean;
begin
  tmp.name := discipline_form.text_fields[GetIndexByNameFromAssociationList(discipline_form.lstcomponents, 'discipline_name_field')].text_value;
  if tmp.name.Length = 0 then error_discipline_name := true;
  if not (error_discipline_name or IsDuplicateDiscipline(tmp, current_edit_discipline_index)) then begin
    disciplines[current_edit_discipline_index].name := tmp.name;
    SaveDisciplinesToFile(DisciplinesFileName);
    current_edit_discipline_index := -1;
    discipline_form.stopped := true;
    FullRender(disciplines_form);
  end else begin
    with err_text do
    begin
      if error_discipline_name then
        title := 'Введите название дисциплины'
      else
        title := 'Данная дисциплина уже существует';
      text_color := LightRed;
      x := (WindowWidth - title.Length) div 2;
      y := WindowHeight - 5;
    end;
    RenderTextComponent(err_text);
    ReadKey;
    ClsSquare(err_text.x, err_text.y, err_text.title.Length, 1);
  end;
end;

procedure OnOpenDisciplineFormEdit(i: integer);
begin
  current_edit_discipline_index := i;
  discipline_form := CreateDisciplineForm();
  discipline_form.window.title := 'Изменение дисциплины';
  
  discipline_form.buttons[GetIndexByNameFromAssociationList(discipline_form.lstcomponents, 'exit_button')].onclick := OnExitDisciplineFormEdit;
  with discipline_form.buttons[GetIndexByNameFromAssociationList(discipline_form.lstcomponents, 'action')] do
  begin
    onclick := OnApplyDisciplineFormEdit;
    title := 'Изменить дисциплину';
    x := (WindowWidth div 2 - title.Length - 2) div 2 + WindowWidth div 2;
  end;
  discipline_form.text_fields[GetIndexByNameFromAssociationList(discipline_form.lstcomponents, 'discipline_name_field')].text_value := disciplines[i].name;
  FullRender(discipline_form);
  EventLoop(discipline_form);
end;

procedure OnOpenDisciplinesTable;
begin
  disciplines_form := CreateDisciplinesForm();
  disciplines_form.buttons[GetIndexByNameFromAssociationList(disciplines_form.lstcomponents, 'exit_button')].onclick := OnExitDisciplinesTable;
  disciplines_form.buttons[GetIndexByNameFromAssociationList(disciplines_form.lstcomponents, 'add_discipline')].onclick := OnOpenDisciplineFormAdd;
  with disciplines_form.tables[GetIndexByNameFromAssociationList(disciplines_form.lstcomponents, 'disciplines_table')] do
  begin
    try
      count_rows := disciplines.Length;
    except
      count_rows := 0;
    end;
    
    get_row := GetRowDiscipline;
    onclick_row := OnOpenDisciplineFormEdit;
    ondelete_row := OnOpenDisciplineFormDelete;
  end;
  FullRender(disciplines_form);
  EventLoop(disciplines_form);
end;

procedure OnExitStipendiaForm;
begin
  stipendia_form.stopped := true;
  FullRender(main_menu);
end;

procedure OnApplyStipendiaForm;
var
  tmp: string;
  tmp_i, i: integer;
  error_stipendia: boolean;
  err_text: TextComponent;
begin
  tmp := stipendia_form.text_fields[GetIndexByNameFromAssociationList(stipendia_form.lstcomponents, 'base_stipendia_field')].text_value;
  try
    tmp_i := StrToInt(tmp);
  except
    error_stipendia := true;
  end;
  if not error_stipendia then begin
    base_stipendia := tmp_i;
    SaveBaseStipendiaToFile(BaseStipendiaFileName);
    for i := 0 to high(students) do
    begin
      if students[i].auto_calculate = 1 then
        CalculateStipendiaForStudent(students[i]);
    end;
    SaveStudentsToFile(StudentsFileName);
    stipendia_form.stopped := true;
    FullRender(main_menu);
  end else begin
    with err_text do
    begin
      title := 'Введите нормальное значение стипендии';
      text_color := LightRed;
      x := (WindowWidth - title.Length) div 2;
      y := WindowHeight - 5;
    end;
    RenderTextComponent(err_text);
    ReadKey;
    ClsSquare(err_text.x, err_text.y, err_text.title.Length, 1);
  end;
end;

procedure OnOpenStipendiaForm;
begin
  stipendia_form := CreateBaseStipendiaForm();
  stipendia_form.text_fields[GetIndexByNameFromAssociationList(stipendia_form.lstcomponents, 'base_stipendia_field')].text_value := IntToStr(base_stipendia);
  stipendia_form.buttons[GetIndexByNameFromAssociationList(stipendia_form.lstcomponents, 'exit_button')].onclick := OnExitStipendiaForm;
  stipendia_form.buttons[GetIndexByNameFromAssociationList(stipendia_form.lstcomponents, 'action')].onclick := OnApplyStipendiaForm;
  FullRender(stipendia_form);
  EventLoop(stipendia_form);
end;

{Процедура отвечающая за логику кнопки входа}
procedure OnAuth();
var
  {Временный аккаунт на этапе проверки}
  account: account_rec;
  {Признак того что такой аккаунт существует}
  is_valid: boolean;
  {Текст в котором будет отображена ошибка}
  err_text: TextComponent;
begin
  {Ищем аккаунт из списка аккаунтов на совпадение логина и пароля, получаем результат в account и is_valid}
  FindAccountByLoginAndPassword(auth_menu.text_fields[0].text_value, auth_menu.text_fields[1].text_value, is_valid, account);
  {Если признак существования аккаунта истина}
  if is_valid then begin
    {Окружение программы запомнит его аккаунт}
    current_account := account;
    {Создает меню}
    main_menu := CreateMenuForm(current_account);
    {Привязываем логику выхода назад в авторизацию}
    main_menu.buttons[GetIndexByNameFromAssociationList(main_menu.lstcomponents, 'exit_button')].onclick := OnExitMenu;
    {Привязываем логику Для администрации}
    if account.admin = 1 then begin
      main_menu.buttons[GetIndexByNameFromAssociationList(main_menu.lstcomponents, 'open_accounts_table')].onclick := OnOpenAccountsTable;
      main_menu.buttons[GetIndexByNameFromAssociationList(main_menu.lstcomponents, 'open_disciplines_table')].onclick := OnOpenDisciplinesTable;
      main_menu.buttons[GetIndexByNameFromAssociationList(main_menu.lstcomponents, 'open_stipendia_form')].onclick := OnOpenStipendiaForm;
    end;
    main_menu.buttons[GetIndexByNameFromAssociationList(main_menu.lstcomponents, 'open_students_table')].onclick := OnOpenStudentsTable;
    {Отображаем меню}
    FullRender(main_menu);
    {Переключаем захват клавиш на данную форму}
    EventLoop(main_menu);
    {Иначе если такого аккаунта не существует}
  end else begin
    {Задаем параметры для создания текста ошибки}
    with err_text do
    begin
      text_color := LightRed;
      title := 'Вы ввели неправильный логин или пароль';
      x := (WindowWidth - title.Length) div 2;
      y := 22;
    end;
    {Отображаем запись текста с определенным стилем}
    RenderTextComponent(err_text);
    {Ожидаем когда пользователь поймет ошибку и продолжит работу с формой}
    ReadKey;
    {Стираем текст после того как пользователь прочел ошибку}
    ClsSquare(err_text.x, err_text.y, err_text.title.Length, 1);
  end;
end;

{Процедура отвечающая за логику выхода из программы}
procedure OnExitAuth();
begin
  {Останавливаем цикл захвата клавиш для формы авторизации}
  auth_menu.stopped := true;
  {Чистим экран}
  ClrScr;
  {Курсору задаем начало консоли}
  gotoxy(1, 1);
  {Программа считается завершенной}
end;

begin
  //apply_dialog := CreateApplyForm();
  //FullRender(apply_dialog);
  //EventLoop(apply_dialog);
  {Стандартный цвет будет белый}
  TextColor(White);
  {Создание стартового окна}
  start_menu := CreateStartMenu();
  {Отображение стартового меню}
  FullRender(start_menu);
  //print(WindowHeight, WindowWidth);
  {Ожидаем когда пользователь нажмет на кнопку для пропуска стартового меню}
  ReadKey;
  {Чтение файла аккаунтов}
  try
    ReadAccountsFile(AccountsFileName);
  except
    SetDefaultAccounts();
  end;
  {Чтение файла студентов}
  try
    ReadStudentsFromFile(StudentsFileName);
  except
    SetLength(students, 0);
  end;
  {Чтение файла с установленной основной стипендией}
  try
    ReadBaseStipendiaFromFile(BaseStipendiaFileName);
  except
    base_stipendia := 3000;
  end;
  {Чтение файла с зарегистрированными дисциплинами}
  try
    ReadDisciplinesFromFile(DisciplinesFileName);
  except
    SetLength(disciplines, 0);
  end;
  {Создание авторизационного меню}
  auth_menu := CreateAuthForm();
  {Приклепление поведения кнопки для входа}
  auth_menu.buttons[0].onclick := OnAuth;
  {Приклепление поведения кнопки для выхода}
  auth_menu.buttons[1].onclick := OnExitAuth;
  {Отображение авторизационного меню}
  FullRender(auth_menu);
  {Переключаем захват клавиш в данную форму}
  EventLoop(auth_menu);
end.