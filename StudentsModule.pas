unit StudentsModule;

interface

uses DisciplinesModule;

type
  {Запись оценки с определенным предметом по его индентификатору}
  mark_rec = record
    discipline_id: integer;
    mark: 1..5;
  end;
  student_rec = record
    {Фамилия, имя и отчество}
    familiya, imya, otchestvo: string;
    {Стипендия}
    stipendia: integer;
    {Будет ли автоматически высчитываться стипендия для данного студента}
    auto_calculate: 0..1;
    {Список в виде связки оценок и предметов}
    marks: array of mark_rec;
  end;

procedure ReadMarks(var student: student_rec);
procedure ReadStudentsFromFile(filename: string);
procedure ReadBaseStipendiaFromFile(filename: string);
procedure WriteMarks(student: student_rec);
procedure SaveStudentsToFile(filename: string);
procedure SaveBaseStipendiaToFile(filename: string);
procedure AddMarkToStudent(var student: student_rec; mark: mark_rec);
procedure AddStudent(student: student_rec);
procedure DeleteMarkForStudent(var student: student_rec; mark: mark_rec);
procedure DeleteStudent(student: student_rec);
procedure CalculateStipendiaForStudent(var student: student_rec);
function GetRowStudent(i: integer): array of string;
function IsDuplicateStudent(student: student_rec; ignore_index: integer): boolean;
function GetRowMark(i: integer): array of string;
function GetRowMarkDenied(i: integer): array of string;


var
  students: array of student_rec;
  current_student: student_rec;
  denied_disciplines_id: array of integer;
  base_stipendia: integer;

implementation

var
  f: text;

function GetMarkByDisciplineId(index: integer): 0..5;
var
  i: integer;
begin
  Result := 0;
  for i := 0 to High(current_student.marks) do
  begin
    if current_student.marks[i].discipline_id = index then begin
      Result := current_student.marks[i].mark;
      break;
    end;
  end;
end;

function GetDisciplineNameById(index: integer): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to high(disciplines) do
  begin
    if disciplines[i].id = index then begin
      Result := disciplines[i].name;
      break;
    end;
  end;
end;

function GetRowStudent(i: integer): array of string;
var
  tmp: array of string;
begin
  setlength(tmp, 4);
  tmp[0] := students[i].familiya;
  tmp[1] := students[i].imya;
  tmp[2] := students[i].otchestvo;
  tmp[3] := IntToStr(students[i].stipendia);
  Result := tmp;
end;

function IsDuplicateStudent(student: student_rec; ignore_index: integer): boolean;
var
  i: integer;
begin
  IsDuplicateStudent := false;
  for i := 0 to high(students) do
  begin
    if (ignore_index <> i) and (students[i].familiya = student.familiya) and (students[i].imya = student.imya) and (students[i].otchestvo = student.otchestvo) then begin
      IsDuplicateStudent := true;
      break;
    end;
  end;
end;

// Считает количество оценок 1,2,3,4,5
function MarkCounter(marks: array of mark_rec): array of integer;
var
  mark_counts: array of integer;
  i: integer;
begin
  SetLength(mark_counts, 5);
  // Проходимся по всем оценкам
  for i := 0 to high(marks) do
  begin
    // Добавляем в копилку количество оценок
    inc(mark_counts[marks[i].mark - 1]);
  end;
  Result := mark_counts;
end;

// Главная функция отвечающая за расчет коэффициента от базовой стипендии для различных типов студентов
function FactorStipendia(marks: array of mark_rec): real;
var
  mark_counts: array of integer;
  factor: real;
  count_disciplines, count_marks: integer;
begin
  mark_counts := MarkCounter(marks);
  try
    count_disciplines := disciplines.Length;
  except
    count_disciplines := 0;
  end;
  try
    count_marks := marks.Length;
  except
    count_marks := 0;
  end;
  // Если есть неудовлетворительные оценки или сданы не все предметы зарегистрированные на данную группу
  if (mark_counts[0] > 0) or (mark_counts[1] > 0) or (count_disciplines > count_marks) then
    // Стипендии не будет
    factor := 0
  // Из предыдущего условия мы знаем что нет удовлетворительных оценок
  // Проверяем на удовлетворительные оценки
  else if mark_counts[2] > 0 then
    // Стипендия будет без надбавки
    factor := 1
  // Мы знаем что он учится без троек
  // Теперь нам надо проверить на хорошиста, преимущественный хорошист(пятерок больше четверок) и отлично успевающему
  else if mark_counts[3] > 0 then
    // Проверка на преимущественного хорошиста
    if mark_counts[3] < mark_counts[4] then
      // Заслуживает губернаторскую стипендию
      factor := 1.30
    else
    // Заслуживает стипендию обычного хорошиста
      factor := 1.25
  // Из предыдущего мы исключили что у него нет оценки 1, 2, 3, 4 т.е. отличник
  else
  // Заслуживает стипендию отличника
    factor := 1.5;
  Result := factor;
end;

function GetRowMark(i: integer): array of string;
var
  tmp: array of string;
begin
  setlength(tmp, 2);
  tmp[0] := GetDisciplineNameById(current_student.marks[i].discipline_id);
  tmp[1] := inttostr(current_student.marks[i].mark);
  Result := tmp;
end;

function GetRowMarkDenied(i: integer): array of string;
var
  tmp: array of string;
begin
  setlength(tmp, 2);
  tmp[0] := GetDisciplineNameById(denied_disciplines_id[i]);
  tmp[1] := inttostr(GetMarkByDisciplineId(denied_disciplines_id[i]));
  Result := tmp;
end;

// Присваивает новую стипендию
procedure CalculateStipendiaForStudent(var student: student_rec);
begin
  student.stipendia := trunc(base_stipendia * FactorStipendia(student.marks));
end;

procedure ReadBaseStipendiaFromFile(filename: string);
begin
  Assign(f, filename);
  Reset(f);
  readln(f, base_stipendia);
  Close(f);
end;

procedure SaveBaseStipendiaToFile(filename: string);
begin
  Assign(f, filename);
  Rewrite(f);
  writeln(f, base_stipendia);
  Close(f);
end;

procedure ReadMarks;
var
  n, i: integer;
begin
  readln(f, n);
  setlength(student.marks, n);
  for i := 0 to n - 1 do
  begin
    with student.marks[i] do
    begin
      readln(f, discipline_id);
      readln(f, mark);
    end;
  end;
end;

procedure ReadStudentsFromFile;
var
  n, i: integer;
begin
  Assign(f, filename);
  Reset(f);
  readln(f, n);
  setlength(students, n);
  for i := 0 to n - 1 do
  begin
    with students[i] do
    begin
      readln(f, familiya);
      readln(f, imya);
      readln(f, otchestvo);
      readln(f, auto_calculate);
      readln(f, stipendia);
    end;
    ReadMarks(students[i]);
  end;
  Close(f);
end;

procedure WriteMarks;
var
  n, i: integer;
begin
  try
    n := student.marks.Length;
  except
    n := 0;
  end;
  Writeln(f, n);
  for i := 0 to n - 1 do
  begin
    with student.marks[i] do
    begin
      writeln(f, discipline_id);
      writeln(f, mark);
    end;
  end;
end;

procedure SaveStudentsToFile;
var
  n, i: integer;
begin
  Assign(f, filename);
  Rewrite(f);
  try
    n := students.Length;
  except
    n := 0;
  end;
  Writeln(f, n);
  for i := 0 to n - 1 do
  begin
    with students[i] do
    begin
      writeln(f, familiya);
      writeln(f, imya);
      writeln(f, otchestvo);
      writeln(f, auto_calculate);
      writeln(f, stipendia);
    end;
    WriteMarks(students[i]);
  end;
  Close(f);
end;

procedure AddMarkToStudent;
var
  n: integer;
begin
  try
    n := student.marks.Length + 1;
  except
    n := 1;
  end;
  SetLength(student.marks, n);
  student.marks[n - 1] := mark;
end;

procedure AddStudent;
var
  n: integer;
begin
  try
    n := students.Length + 1;
  except
    n := 1;
  end;
  SetLength(students, n);
  students[n - 1] := student;
end;

procedure DeleteMarkForStudent;
var
  i: integer;
begin
  for i := 0 to high(student.marks) do
  begin
    if student.marks[i].discipline_id = mark.discipline_id then begin
      student.marks[i] := student.marks[high(student.marks)];
      setlength(student.marks, high(student.marks));
      break;
    end;
  end;
end;

procedure DeleteStudent;
var
  i: integer;
begin
  for i := 0 to high(students) do
  begin
    if (students[i].Familiya = student.Familiya) and (students[i].imya = student.imya) and (students[i].otchestvo = student.otchestvo) then begin
      students[i] := students[high(students)];
      setlength(students, high(students));
      break;
    end;
  end;
end;

begin

end. 