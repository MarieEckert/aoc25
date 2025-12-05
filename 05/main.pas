{$mode objfpc}
program main;

{$ModeSwitch ArrayOperators}

uses
	Math,
	SysUtils;

type
	TRange = record
		first: Int64;
		last: Int64;
	end;

	TRanges = array of TRange;

procedure BSort(var ranges: TRanges);
var
	n, newn, i	: UInt64;
	temp		: TRange;
begin
	n := High(ranges);
	repeat
		newn := 0;
		for i := 1 to n do
		begin
			if ranges[i-1].first <= ranges[i].first then
				continue;

			temp := ranges[i-1];
			ranges[i-1] := ranges[i];
			ranges[i] := temp;
			newn := i;
		end ;
		n := newn;
	until n = 0;
end;


function TryCombine(var dest: TRange; const second: TRange): Boolean;
begin
	if (second.first > dest.last)
	or (second.last < dest.first) then
		exit(False);

	dest.first	:=  Min(dest.first, second.first);
	dest.last	:= Max(dest.last, second.last);
	exit(True);
end;

function CombineExisting(ranges: TRanges): TRanges;
var
	ix: UInt64;
begin
	SetLength(result, 0);

	BSort(ranges);

	for ix := 0 to Length(ranges) - 1 do
	begin
		if ranges[ix].first < 0 then
			continue;

		if ix + 1 < Length(ranges) then
		begin
			if TryCombine(ranges[ix], ranges[ix + 1]) then
				ranges[ix + 1].first := -1
			else if TryCombine(ranges[ix + 1], ranges[ix]) then
			begin
				ranges[ix] := ranges[ix + 1];
				ranges[ix + 1].first := -1;
			end;
		end;

		result += [ranges[ix]];
	end;
end;

procedure AddOrCombineRange(var ranges: TRanges; range: TRange);
var
	ix: UInt64;
begin
	if Length(ranges) = 0 then
	begin
		ranges += [range];
		exit;
	end;

	if Length(ranges) > 1 then
		ranges := CombineExisting(ranges);

	for ix := 0 to Length(ranges) - 1 do
	begin
		if TryCombine(ranges[ix], range) then
			exit;
		if TryCombine(range, ranges[ix]) then
		begin
			ranges[ix] := range;
			exit;
		end;
	end;

	ranges += [range];
end;

procedure CheckFresh(const ingredient: Int64; const ranges: TRanges; var counter: UInt64);
var
	range: TRange;
begin
	for range in ranges do
	begin
		if (range.first > ingredient)
		or (range.last < ingredient) then
			continue;

		Inc(counter);
		exit;
	end;
end;

var
	readingRanges	: Boolean;
	line			: String;
	range			: TRange;
	sep, total		: UInt64;
	ranges			: TRanges;
begin
	readingRanges := True;
	
	SetLength(ranges, 0);

	total := 0;

	while not Eof(Input) do
	begin
		ReadLn(line);
		line := Trim(line);

		if not readingRanges then
		begin
			CheckFresh(StrToInt64(line), ranges, total);
			continue;
		end;

		if Length(line) = 0 then
		begin
			readingRanges := False;
			ranges := CombineExisting(ranges);
			continue;
		end;

		sep := Pos('-', line);
		range.first := StrToInt64(Copy(line, 1, sep - 1));
		range.last := StrToInt64(Copy(line, sep + 1, Length(line) - sep));

		AddOrCombineRange(ranges, range);
	end;

	WriteLn('part one: ', total);

	total := 0;
	for range in ranges do
		total += range.last - range.first + 1;

	WriteLn('part two: ', total);
end.