unit DisciplinesModule;

interface

const
  DeletedIndexesDisciplinesFileName = 'deleted_indexes_disciplines.dat';

type
  discipline_rec = record
    id: integer;
    name: string;
  end;

var
  disciplines: array of discipline_rec;

procedure ReadDisciplinesFromFile(filename: string);
procedure AddDiscipline(discipline: discipline_rec);
procedure DeleteDiscipline(discipline: discipline_rec);
procedure SaveDisciplinesToFile(filename: string);
function IsDuplicateDiscipline(discipline: discipline_rec; ignore_index: integer): boolean;
function GetRowDiscipline(i: integer): array of string;

implementation

var
  f: text;
  deleted_indexes: array of integer;

procedure SaveDeletedIndexes;
var
  n, i: integer;
begin
  Assign(f, DeletedIndexesDisciplinesFileName);
  Rewrite(f);
  try
    n := deleted_indexes.Length;
  except
    n := 0;
  end;
  writeln(f, n);
  for i := 0 to n - 1 do
  begin
    Writeln(f, deleted_indexes[i]);
  end;
  Close(f);
end;

procedure AddDeletedIndexes(index: integer);
var
  n: integer;
begin
  try
    n := deleted_indexes.Length;
  except
    n := 0;
  end;
  setlength(deleted_indexes, n + 1);
  deleted_indexes[n] := index;
  SaveDeletedIndexes();
end;

procedure DeleteDeletedIndexes(index: integer);
var
  i: integer;
begin
  for i := 0 to high(deleted_indexes) do
  begin
    if deleted_indexes[i] = index then begin
      Swap(deleted_indexes[i], deleted_indexes[high(deleted_indexes)]);
      setlength(deleted_indexes, high(deleted_indexes));
      break;
    end;
  end;
end;

function NextDisciplineIndex: integer;
var
  n, i: integer;
begin
  try
    n := disciplines.Length;
  except
    n := 0;
  end;
  setlength(disciplines, n + 1);
  Result := -1;
  for i := 0 to high(deleted_indexes) do
  begin
    if i = 0 then begin
      Result := deleted_indexes[i];
      DeleteDeletedIndexes(i);
      SaveDeletedIndexes();
      break;
    end;
  end;
  
  if Result = -1 then begin
    NextDisciplineIndex := n;
  end;
end;

function IsDuplicateDiscipline(discipline: discipline_rec; ignore_index: integer): boolean;
var
  i: integer;
begin
  IsDuplicateDiscipline := false;
  for i := 0 to high(disciplines) do
  begin
    if (ignore_index <> i) and (disciplines[i].name = discipline.name) then begin
      IsDuplicateDiscipline := true;
      break;
    end;
  end;
end;

procedure ReadDisciplinesFromFile;
var
  n, i: integer;
begin
  Assign(f, filename);
  Reset(f);
  readln(f, n);
  setlength(disciplines, n);
  for i := 0 to n - 1 do
  begin
    with disciplines[i] do
    begin
      readln(f, id);
      readln(f, name);
    end;
  end;
  Close(f);
end;

function GetRowDiscipline(i: integer): array of string;
var
  tmp: array of string;
begin
  setlength(tmp, 1);
  tmp[0] := disciplines[i].name;
  Result := tmp;
end;

procedure AddDiscipline;
var
  n: integer;
begin
  try
    n := disciplines.Length + 1;
  except
    n := 1;
  end;
  discipline.id := NextDisciplineIndex();
  disciplines[n - 1] := discipline;
end;

procedure DeleteDiscipline;
var
  i: integer;
begin
  for i := 0 to high(disciplines) do
  begin
    if disciplines[i].id = discipline.id then begin
      AddDeletedIndexes(discipline.id);
      disciplines[i] := disciplines[high(disciplines)];
      setlength(disciplines, high(disciplines));
      break;
    end;
  end;
end;

procedure SaveDisciplinesToFile;
var
  n, i: integer;
begin
  Assign(f, filename);
  Rewrite(f);
  try
    n := disciplines.Length;
  except
    n := 0;
  end;
  Writeln(f, n);
  for i := 0 to n - 1 do
  begin
    with disciplines[i] do
    begin
      writeln(f, id);
      writeln(f, name);
    end;
  end;
  Close(f);
end;

begin
end. 