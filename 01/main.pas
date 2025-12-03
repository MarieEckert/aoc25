{$mode objfpc}
program main;

{$scopedenums on}

uses
	Math,
	SysUtils;

type
	TDirection = (Left=-1,Right=1);

var
	line			: String;
	state			: Int64;
	previous		: Int64;
	num				: UInt16;
	zeroes, crosses	: UInt32;	{ zeroes: part one; crosses: part two }
	prev, curr		: Int64;	{ difference in hundreds }
	direction		: TDirection = TDirection.Left;
begin
	state := 50;
	zeroes := 0;
	crosses := 0;
	while not Eof(Input) do
	begin
		ReadLn(line);
		line := Trim(line);
		if Length(line) = 0 then
			continue;

		if line[1] = 'L' then
			direction := TDirection.Left
		else if line[1] = 'R' then
			direction := TDirection.Right;

		previous := state;
		num := StrToInt(Copy(line, 2, Length(line)-1));
		state += Ord(direction) * num;

		if (state mod 100) = 0 then
			Inc(zeroes);

		curr := Floor(state / 100);
		prev := Floor(previous / 100);
		crosses += Abs(curr - prev);

		if direction <> TDirection.Left then
			continue;

		if (state mod 100) = 0 then
			Inc(crosses);
		if (previous mod 100) = 0 then
			Dec(crosses);
	end;

	WriteLn('part one result: ', zeroes);
	WriteLn('part two result: ', crosses);
end.