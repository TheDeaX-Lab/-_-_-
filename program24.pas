﻿uses crt, PseudoGraphic, Forms, Authentication;

var
  {Окружение программы}
  {Используемые формы:
  0) Конец
  1) Стартовое окно "Титульный лист"
  2) Авторизация (Может перейти в 0 или 3)
  3) Меню (Может перейти в 1, 4 или 5)
  4) Таблица студентов, удаление можно будет воспроизвести при помощи кнопки Delete (Может перейти в 3 или 7)
  5) Таблица аккаунтов, удаление можно будет воспроизвести при помощи кнопки Delete (Может перейти в 3 или 6)
  6) Форма заполнения аккаунта, либо чтение, либо добавление, либо изменение (Может перейти в 5 или 10)
  7) Форма заполнения студента, либо чтение, либо добавление, либо изменение (Может перейти в 4 или 10)
  8) Форма таблицы оценок текущего выбранного студента (Может перейти в 7 или 9)
  9) Форма заполнения предмета и оценки (Может перейти в 8 или 10)
  10) Форма подтверждения действия (Является формой подтверждения для 6, 7, 9 при подтвеждении выхода без сохранения информации студенту)
  11) Добавление предмета в список существующих
  }
  start_menu, auth_menu, main_menu, accounts_form, account_form, students_form, student_form, marks_form, mark_form, apply_dialog: GuiComponents;
  {Текущий рабочий аккаунт для пользователя}
  current_account: account_rec;

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
  {Очищаем экран}
  ClrScr;
  {Отображаем форму авторизации}
  FullRender(auth_menu);
  {После того как процедура сработала, помним о стеке:
  Меню было вызвано формой авторизации}
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
    main_menu.buttons[high(main_menu.buttons)].onclick := OnExitMenu;
    {Отображаем меню}
    FullRender(main_menu);
    {Переключаем захват клавиш на данную форму}
    EventLoop(main_menu);
  {Иначе если такого аккаунта не существует}
  end else begin
    {Сохраняем первоначальную позицию курсора}
    save_x := WhereX;
    save_y := WhereY;
    {Переходим на строку для вывода ошибки}
    gotoxy(2, 22);
    {Делаем красный шрифт}
    TextColor(LightRed);
    {Выводим ошибку пользователю}
    write('Вы ввели неправильный логин или пароль');
    {Меняем шрифт на стандартный}
    TextColor(White);
    {Возвращаем курсор в первоначальное место}
    gotoxy(save_x, save_y);
  end;
  {gotoxy(2, 22);
  TextColor(Green);
  write('Ура! Теперь осталось проверить данные полей и перенаправить пользователя на другую панель');
  TextColor(White);}
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
  {Создание стартового окна}
  start_menu := CreateStartMenu();
  {Отображение стартового меню}
  FullRender(start_menu);
  {Ожидаем когда пользователь нажмет на кнопку для пропуска стартового меню}
  ReadKey;
  {Чтение файла аккаунтов}
  ReadAccountsFile('accounts.dat');
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