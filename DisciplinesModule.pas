Unit DisciplinesModule;
interface
type
  discipline_rec = record
    id : integer;
    name: string;
  end;
var
  disciplines : array of discipline_rec;

procedure ReadDisciplinesFromFile(filename: string);
procedure AddDiscipline(discipline: discipline_rec);
procedure DeleteDiscipline(discipline: discipline_rec);
procedure SaveDisciplinesToFile(filename: string);

implementation
var
  f : text;

procedure ReadDisciplinesFromFile;
var
  n, i : integer;
begin
  Assign(f, filename);
  Reset(f);
  readln(f, n);
  setlength(disciplines, n);
  for i:=0 to n - 1 do begin
    with disciplines[i] do begin
      readln(f, id);
      readln(f, name);
    end;
  end;
  Close(f);
end;

procedure AddDiscipline;
var
  n : integer;
begin
  try
    n := disciplines.Length + 1;
  except
    n := 1;
  end;
  disciplines[n - 1] := discipline;
end;
procedure DeleteDiscipline;
var
  i : integer;
begin
  for i:=0 to high(disciplines) do begin
    if disciplines[i].id = discipline.id then begin
      disciplines[i] := disciplines[high(disciplines)];
      setlength(disciplines, high(disciplines))
    end;
  end;
end;
procedure SaveDisciplinesToFile;
var
  n, i : integer;
begin
  Assign(f, filename);
  Rewrite(f);
  try
    n := disciplines.Length;
  except
    n := 0;
  end;
  Writeln(f, n);
  for i := 0 to n - 1 do begin
    with disciplines[i] do begin
      writeln(f, id);
      writeln(f, name);
    end;
  end;
  Close(f);
end;

begin
end.