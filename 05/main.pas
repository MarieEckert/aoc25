{$mode objfpc}
program main;

uses
	SysUtils;

type
	TRange = record
		first: Int64;
		last: Int64;
	end;

	TRanges = array of TRange;

procedure BSort(var ranges: TRanges);

	procedure Swap(var a, b: TRange);
	var
		temp : TRange;
	begin
		temp := a;
		a := b;
		b := temp;
	end;

var
	n, newn, i: UInt64;
begin
	n := High(ranges);
	repeat
		newn := 0;
		for i := 1 to n do
		begin
			if ranges[i - 1].first <= ranges[i].first then
				continue;
			swap(ranges[i - 1], ranges[i]);
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
	
	if dest.first > second.first then
		dest.first :=  second.first;
	if dest.last < second.last then
		dest.last := second.last;

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

		if ix + 1 = Length(ranges) then
		begin
			SetLength(result, Length(result) + 1);
			result[High(result)] := ranges[ix];
			break;
		end;

		if TryCombine(ranges[ix], ranges[ix + 1]) then
			ranges[ix + 1].first := -1
		else if TryCombine(ranges[ix + 1], ranges[ix]) then
		begin
			ranges[ix] := ranges[ix + 1];
			ranges[ix + 1].first := -1;
		end;

		SetLength(result, Length(result) + 1);
		result[High(result)] := ranges[ix];
	end;
end;

procedure AddOrCombineRange(var ranges: TRanges; range: TRange);
var
	ix: UInt64;
begin
	if Length(ranges) = 0 then
	begin
		SetLength(ranges, 1);
		ranges[0] := range;
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

	SetLength(ranges, Length(ranges) + 1);
	ranges[High(ranges)] := range;
end;

var
	readingRanges	: Boolean;
	line			: String;
	tmpRange		: TRange;
	tmpUInt, total	: UInt64;
	ranges			: TRanges;
begin
	readingRanges := True;
	
	SetLength(ranges, 0);

	total := 0;

	while not Eof(Input) do
	begin
		ReadLn(line);
		line := Trim(line);
		if readingRanges and (Length(line) = 0) then
		begin
			readingRanges := False;
			ranges := CombineExisting(ranges);
			continue;
		end;

		if readingRanges then
		begin
			tmpUInt := Pos('-', line);
			tmpRange.first := StrToInt64(Copy(line, 1, tmpUInt - 1));
			tmpRange.last := 
				StrToInt64(Copy(line, tmpUInt + 1, Length(line) - tmpUInt));
			AddOrCombineRange(ranges, tmpRange);
			continue;
		end;

		tmpUInt := StrToUInt64(line);
		for tmpRange in ranges do
		begin
			if (tmpRange.first > tmpUInt) or (tmpRange.last < tmpUInt) then
				continue;

			Inc(total);
			break;
		end;
	end;

	WriteLn('part one: ', total);

	total := 0;
	for tmpRange in ranges do
		total += tmpRange.last - tmpRange.first + 1;

	WriteLn('part two: ', total);
end.