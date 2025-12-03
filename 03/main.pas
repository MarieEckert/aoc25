{$mode objfpc}
program main;

{$scopedenums on}

uses
	SysUtils;

type
	TUInt8DynArray = array of UInt8;

function FindLargest(const batteries: TUInt8DynArray; k: Integer): UInt64;
var
	n, i		: Integer;
	stack		: array of UInt8;
	top			: Integer; { current size of the stack }
	toRemove	: Integer; { how many digits we are still allowed to drop }
	digit		: UInt8;
begin
	n := Length(batteries);

	if (k <= 0) or (n = 0) then
	begin
		result := 0;
		exit;
	end;

	if k > n then
		k := n;

	toRemove := n - k;

	SetLength(stack, k);
	top := 0;

	for i := 0 to n - 1 do
	begin
		digit := batteries[i];

		{
			While last chosen digit is smaller than current and we can still
			drop digits, pop it to make room for a larger number.
		}
		while (top > 0) and (stack[top - 1] < digit) and (toRemove > 0) do
		begin
			Dec(top);
			Dec(toRemove);
		end;

		{ If we still need more digits to reach length k, push this one }
		if top < k then
		begin
			stack[top] := digit;
			Inc(top);
		end
		else
		begin
			{
				we already have k digits, but we might still be allowed to
				drop some later; in that case, we just "drop" the current digit
				by not pushing it.
			}
			if toRemove > 0 then
				Dec(toRemove);
		end;
	end;

	result := 0;
	for i := 0 to k - 1 do
		result := result * 10 + stack[i];
end;

var
	batteries: TUInt8DynArray;
	line: String;
	ix: UInt32;
	sum: UInt64;
	max: UInt64;
begin
	if ParamCount < 1 then
	begin
		max := 2;
		WriteLn(
			StdErr,
			'HINT: specify the maximum number of batteries as the first arg'
		);
	end else
	begin
		if not TryStrToUInt64(ParamStr(1), max) then
		begin
			WriteLn(StdErr, 'invalid integer "', ParamStr(1),'"');
			Halt(1);
		end;
	end;

	sum := 0;

	while not Eof(Input) do
	begin
		ReadLn(line);
		line := Trim(line);
		SetLength(batteries, Length(line));
		for ix := 1 to Length(line) do
			batteries[ix-1] := StrToInt(line[ix]);

		sum += FindLargest(batteries, max);
	end;

	WriteLn('part one: ', sum);
end.