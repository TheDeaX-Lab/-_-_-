unit Authentication;

interface

type
  account_rec = record
    login, password: string;
    admin: 0..1;
  end;

procedure FindAccountByLoginAndPassword(login, password: string; var is_found: boolean; var account: account_rec);
function IsDuplicateAccount(account: account_rec; ignore_index : integer): boolean;
procedure RemoveAccount(account: account_rec);
procedure AddAccount(account: account_rec);
procedure ReadAccountsFile(filename: string);
procedure SaveAccountsFile(filename: string);
function CreateAccount(lg, ps: string; adm: integer): account_rec;
function GetAccountRow(i: integer): array of string;
var
  accounts: array of account_rec;

implementation

var
  f: text;

function CreateAccount: account_rec;
var
  tmp: account_rec;
begin
  with tmp do
  begin
    login := lg;
    password := ps;
    admin := adm;
  end;
  Result := tmp;
end;

function GetAccountRow(i: integer): array of string;
var
  tmp : array of string;
begin
  setlength(tmp, 3);
  tmp[0] := accounts[i].login;
  tmp[1] := accounts[i].password;
  tmp[2] := IntToStr(accounts[i].admin);
  Result := tmp;
end;

function IsDuplicateAccount(account: account_rec; ignore_index : integer): boolean;
var
  i : integer;
begin
  IsDuplicateAccount := false;
  for i := 0 to High(accounts) do begin
    if (ignore_index <> i) and (account.login = accounts[i].login) then begin
     IsDuplicateAccount := true;
     break;
    end;
  end;
end;

procedure AddAccount;
var
  n : integer;
begin
  try
    n := accounts.Length + 1;
  except
    n := 1;
  end;
  setlength(accounts, n);
  accounts[n - 1] := account;
end;

procedure RemoveAccount;
var
  i : integer;
begin
  for i := 0 to High(accounts) do begin
    if (account.login = accounts[i].login) and (account.password = accounts[i].password) then begin
      accounts[i] := accounts[High(accounts)];
      SetLength(accounts, High(accounts));
      break;
    end;
  end;
end;

procedure ReadAccountsFile;
var
  n, i: integer;
  login, password: string;
  admin: integer;
begin
  setlength(accounts, 0);
  Assign(f, filename);
  Reset(f);
  readln(f, n);
  setlength(accounts, n);
  for i := 0 to n - 1 do
  begin
    Readln(f, login);
    Readln(f, password);
    Readln(f, admin);
    accounts[i] := CreateAccount(login, password, admin);
  end;
  Close(f);
end;

procedure SaveAccountsFile;
var
  n, i: integer;
begin
  Assign(f, filename);
  Rewrite(f);
  n := accounts.Length;
  Writeln(f, n);
  for i := 0 to n - 1 do
  begin
    with accounts[i] do
    begin
      Writeln(f, login);
      Writeln(f, password);
      Writeln(f, admin);
    end;
  end;
  Close(f);
end;

procedure FindAccountByLoginAndPassword;
var
  i: integer;
begin
  is_found := false;
  for i := 0 to High(accounts) do
  begin
    if (accounts[i].login = login) and (accounts[i].password = password) then begin
      account := accounts[i];
      is_found := true;
      break;
    end;
  end;
end;

begin

end. 