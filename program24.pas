uses crt, PseudoGraphic, Forms, Authentication, StudentsModule;

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
  marks_form, mark_form,
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
  err_text: TextComponent;
begin
  current_add_account.login := account_form.text_fields[GetIndexByNameFromAssociationList(account_form.lstcomponents, 'login_field')].text_value;
  current_add_account.password := account_form.text_fields[GetIndexByNameFromAssociationList(account_form.lstcomponents, 'password_field')].text_value;
  current_add_account.admin := account_form.selects[GetIndexByNameFromAssociationList(account_form.lstcomponents, 'admin_field')].selected_index;
  if not IsDuplicateAccount(current_add_account, -1) then begin
    AddAccount(current_add_account);
    SaveAccountsFile(AccountsFileName);
    current_add_account := clr_acc;
    account_form.stopped := true;
    inc(accounts_form.tables[GetIndexByNameFromAssociationList(accounts_form.lstcomponents, 'accounts_table')].count_rows);
    FullRender(accounts_form);
  end else begin
    with err_text do
    begin
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
begin
  account_form := CreateAccountForm();
  account_form.window.title := 'Добавление аккаунта';
  account_form.buttons[GetIndexByNameFromAssociationList(account_form.lstcomponents, 'action')].onclick := OnApplyAccountFormAdd;
  account_form.buttons[GetIndexByNameFromAssociationList(account_form.lstcomponents, 'action')].title := 'Добавить аккаунт';
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
  err_text: TextComponent;
begin
  tmp.login := account_form.text_fields[GetIndexByNameFromAssociationList(account_form.lstcomponents, 'login_field')].text_value;
  tmp.password := account_form.text_fields[GetIndexByNameFromAssociationList(account_form.lstcomponents, 'password_field')].text_value;
  tmp.admin := account_form.selects[GetIndexByNameFromAssociationList(account_form.lstcomponents, 'admin_field')].selected_index;
  if not IsDuplicateAccount(tmp, current_edit_account_index) then begin
    accounts[current_edit_account_index] := tmp;
    SaveAccountsFile(AccountsFileName);
    current_edit_account_index := -1;
    account_form.stopped := true;
    FullRender(accounts_form);
  end else begin
    with err_text do
    begin
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
  account_form.buttons[GetIndexByNameFromAssociationList(account_form.lstcomponents, 'action')].onclick := OnApplyAccountFormEdit;
  account_form.buttons[GetIndexByNameFromAssociationList(account_form.lstcomponents, 'action')].title := 'Изменить аккаунт';
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
begin
  current_add_student.familiya := student_form.text_fields[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'familiya_field')].text_value;
  current_add_student.imya := student_form.text_fields[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'imya_field')].text_value;
  current_add_student.otchestvo := student_form.text_fields[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'otchestvo_field')].text_value;
  current_add_student.stipendia := StrToInt(student_form.text_fields[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'stipendia_field')].text_value);
  current_add_student.auto_calculate := student_form.selects[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'auto_calculate_field')].selected_index;
  if not IsDuplicateStudent(current_add_student, -1) then begin
    AddStudent(current_add_student);
    SaveStudentsToFile(StudentsFileName);
    inc(students_form.tables[GetIndexByNameFromAssociationList(students_form.lstcomponents, 'students_table')].count_rows);
    current_add_student := clr_stud;
    student_form.stopped := true;
    FullRender(students_form);
  end else begin
    with err_text do
    begin
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
  student_form := CreateStudentForm(current_account);
  student_form.window.title := 'Добавление студента';
  student_form.buttons[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'exit_button')].onclick := OnExitStudentFormAdd;
  if current_account.admin = 1 then begin
    with student_form.buttons[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'action')] do
    begin
      title := 'Добавить студента';
      x := (WindowWidth div 3 - title.Length - 2) div 2 + WindowWidth div 3;
      onclick := OnApplyStudentFormAdd;
    end;
  end;
  
  FullRender(student_form);
  EventLoop(student_form);
end;

procedure OnExitStudentFormEdit;
begin
  student_form.stopped := true;
  FullRender(students_form);
end;

procedure OnApplyStudentFormEdit;
var
  tmp: student_rec;
  err_text: TextComponent;
begin
  tmp.familiya := student_form.text_fields[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'familiya_field')].text_value;
  tmp.imya := student_form.text_fields[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'imya_field')].text_value;
  tmp.otchestvo := student_form.text_fields[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'otchestvo_field')].text_value;
  tmp.stipendia := StrToInt(student_form.text_fields[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'stipendia_field')].text_value);
  tmp.auto_calculate := student_form.selects[GetIndexByNameFromAssociationList(student_form.lstcomponents, 'auto_calculate_field')].selected_index;
  if not IsDuplicateStudent(tmp, current_edit_student_index) then begin
    students[current_edit_student_index] := tmp;
    SaveStudentsToFile(StudentsFileName);
    current_edit_student_index := -1;
    student_form.stopped := true;
    FullRender(students_form);
  end else begin
    with err_text do
    begin
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


procedure OnOpenStudentFormEdit(i: integer);
begin
  current_edit_student_index := i;
  student_form := CreateStudentForm(current_account);
  if current_account.admin = 1 then
    student_form.window.title := 'Изменение аккаунта'
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

{Процедура отвечающая за логику кнопки входа}
procedure OnAuth();
var
  {Временный аккаунт на этапе проверки}
  account: account_rec;
  {Признак того что такой аккаунт существует}
  is_valid: boolean;
  {Временное сохранение последнее нахождение курсора}
  save_x, save_y: integer;
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
    end;
    main_menu.buttons[GetIndexByNameFromAssociationList(main_menu.lstcomponents, 'open_students_table')].onclick := OnOpenStudentsTable;
    {Отображаем меню}
    FullRender(main_menu);
    {Переключаем захват клавиш на данную форму}
    EventLoop(main_menu);
    {Иначе если такого аккаунта не существует}
  end else begin
    {Сохраняем первоначальную позицию курсора}
    save_x := WhereX;
    save_y := WhereY;
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
    {Возвращаемся на исходную позицию}
    gotoxy(save_x, save_y);
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
  {Ожидаем когда пользователь нажмет на кнопку для пропуска стартового меню}
  ReadKey;
  {Чтение файла аккаунтов}
  ReadAccountsFile(AccountsFileName);
  {Чтение файла студентов}
  ReadStudentsFromFile(StudentsFileName);
  {Чтение файла с установленной основной стипендией}
  ReadBaseStipendiaFromFile(BaseStipendiaFileName);
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