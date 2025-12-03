{$mode objfpc}
program main;

{$scopedenums on}

uses
	Character,
	Math,
	SysUtils;

type
	TUInt64DynArray = array of UInt64;

function FindInvalids(lower: UInt64; upper: UInt64): TUInt64DynArray;
var
	n, p		: UInt64;
	digitCount	: UInt8;
begin
	SetLength(result, 0);

	for n := lower to upper do
	begin
		digitCount := Floor(Log10(n)) + 1;

		if (digitCount mod 2) <> 0 then
			continue;

		p := Round(Power(10, digitCount div 2));

		if Floor(n / p) <> (n mod p) then
			continue;

		SetLength(result, Length(result) + 1);
		result[High(result)] := n;
	end;
end;

function FindInvalids2(lower: UInt64; upper: UInt64): TUInt64DynArray;
var
	n, blockLen, p, i, blocks	: UInt64;
	pattern, tmp				: UInt64;
	digitCount					: UInt8;
	ok, same					: Boolean;
begin
	SetLength(result, 0);

	for n := lower to upper do
	begin
		digitCount := Floor(Log10(n)) + 1;

		ok := False;
		for blockLen := (digitCount div 2) downto 1 do
		begin
			if ((digitCount mod blockLen) <> 0) then
				continue;

			blocks := digitCount div blockLen;
			if blocks < 2 then
				continue;

			p := Round(Power(10, blockLen));

			pattern := n mod p;
			tmp := n div p;

			same := True;

			for i := 2 to blocks do
			begin
				if (tmp mod p) <> pattern then
				begin
					same := False;
					break;
				end;
				tmp := tmp div p;
			end;

			if same then
			begin
				ok := True;
				break;
			end;
		end;

		if not ok then continue;

		SetLength(result, Length(result) + 1);
		result[High(result)] := n;
	end;
end;

var
	ch: Char;
	buf: String;
	lower, upper: UInt64;
	sum, sum2, n: UInt64;
begin
	buf := '';
	sum := 0;
	while not Eof(Input) do
	begin
		Read(ch);
		if ch = '-' then
		begin
			lower := StrToUInt64(buf);
			buf := '';
		end else if (ch = ',') or Eof(Input) then
		begin
			{ If we are at the EOF we have already read the last digit but not
			  added it to buf
			}
			if IsDigit(ch) then
				buf+=ch;

			upper := StrToUInt64(buf);
			buf := '';
			
			WriteLn('Finding duplicates in range ', lower, '-', upper);
			for n in FindInvalids(lower, upper) do
				sum += n;

			for n in FindInvalids2(lower, upper) do
				sum2 += n;
		end else
			buf += ch;
	end;

	WriteLn('part one: ', sum);
	WriteLn('part two: ', sum2);
end.