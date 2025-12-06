{$mode objfpc}
program main;

{$ModeSwitch ArrayOperators}
{$ScopedEnums On}
{$H+}

uses
	Character,
	StrUtils,
	SysUtils,
	Types;

type
	TRow = array of UInt64;
	TRows = array of TRow;
	TOperation = (Add, Multiply);
	TOperations = array of TOperation;
	TLines = array of String;

	TColGroup = record
		startCol, endCol: SizeInt;
	end;
	TColGroups = array of TColGroup;

function CharAt(const s: String; index: SizeInt): Char; inline;
begin
	if (index < 1) or (index > Length(s)) then
		result := ' '
	else
		result := s[index];
end;

procedure ParseNormal(const lines: TLines; out rows: TRows; out ops: TOperations);
var
	line, norm	: String;
	parts		: TStringDynArray;
	row			: TRow;
	colCount	: SizeInt;
	i, li		: SizeInt;
begin
	SetLength(rows, 0);
	SetLength(ops, 0);
	colCount := 0;

	for li := 0 to High(lines) do
	begin
		line := lines[li];
		norm := DelSpace1(Trim(line));

		if not IsDigit(norm[1]) then
		begin
			parts := SplitString(norm, ' ');
			SetLength(ops, Length(parts));
			for i := 0 to High(parts) do
				if parts[i] = '+' then
					ops[i] := TOperation.Add
				else
					ops[i] := TOperation.Multiply;
			break;
		end
		else
		begin
			parts := SplitString(norm, ' ');
			if colCount = 0 then
				colCount := Length(parts);

			SetLength(row, colCount);
			for i := 0 to colCount - 1 do
				row[i] := StrToUInt64(parts[i]);

			rows += [row];
		end;
	end;
end;

procedure ParseCephalopod(
	const lines	: TLines;
	out rows	: TRows;
	out ops		: TOperations
);

	procedure AddGroup(var groups: TColGroups; const startCol, endCol: SizeInt);
	var
		val: TColGroup;
	begin
		val.startCol := startCol;
		val.endCol := endCol;
		groups += [val];
	end;

var
	rowTotal, digitRows, maxWidth	: SizeInt;
	rowIx, colIx					: SizeInt;
	groups							: TColGroups;
	inGroup							: Boolean;
	hasDigits						: Boolean;
	startCol						: SizeInt;
	colCount, rowCount				: SizeInt;
	groupIx							: SizeInt;
	groupStart, groupEnd, groupWidth: SizeInt;
	ch, opChar						: Char;
	digits							: String;
	rr								: SizeInt; { inner row index }
	padValue						: UInt64;
begin
	rowTotal := Length(lines);
	if rowTotal = 0 then
		exit;
	digitRows := rowTotal - 1;

	maxWidth := 0;
	for rowIx := 0 to rowTotal - 1 do
		if Length(lines[rowIx]) > maxWidth then
			maxWidth := Length(lines[rowIx]);

	SetLength(groups, 0);
	inGroup := False;

	for colIx := 1 to maxWidth + 1 do
	begin
		hasDigits := False;

		if colIx <= maxWidth then
			for rowIx := 0 to digitRows - 1 do
			begin
				ch := CharAt(lines[rowIx], colIx);
				if IsDigit(ch) then
				begin
					hasDigits := True;
					break;
				end;
			end;

		if hasDigits then
		begin
			if not inGroup then
			begin
				inGroup := True;
				startCol := colIx;
			end;
		end
		else if inGroup then
		begin
			AddGroup(groups, startCol, colIx - 1);
			inGroup := False;
		end;
	end;

	colCount := Length(groups);
	if colCount = 0 then
		exit;

	rowCount := 0;
	for groupIx := 0 to colCount - 1 do
	begin
		groupWidth := groups[groupIx].endCol - groups[groupIx].startCol + 1;
		if groupWidth > rowCount then
			rowCount := groupWidth;
	end;

	SetLength(rows, rowCount);
	for rowIx := 0 to rowCount - 1 do
		SetLength(rows[rowIx], colCount);
	SetLength(ops, colCount);

	for groupIx := 0 to colCount - 1 do
	begin
		groupStart := groups[groupIx].startCol;
		groupEnd := groups[groupIx].endCol;
		groupWidth := groupEnd - groupStart + 1;

		opChar := '*';
		for colIx := groupStart to groupEnd do
		begin
			ch := CharAt(lines[digitRows], colIx);
			if (ch = '+') or (ch = '*') then
			begin
				opChar := ch;
				break;
			end;
		end;

		if opChar = '+' then
			ops[groupIx] := TOperation.Add
		else
			ops[groupIx] := TOperation.Multiply;

		if ops[groupIx] = TOperation.Multiply then
			padValue := 1
		else
			padValue := 0;

		for rowIx := 0 to rowCount - 1 do
		begin
			if rowIx < groupWidth then
			begin
				colIx  := groupEnd - rowIx;
				digits := '';

				for rr := 0 to digitRows - 1 do
				begin
					ch := CharAt(lines[rr], colIx);
					if IsDigit(ch) then
						digits := digits + ch;
				end;

				if Length(digits) > 0 then
					rows[rowIx][groupIx] := StrToUInt64(digits)
				else
					rows[rowIx][groupIx] := padValue;

				continue;
			end;

			rows[rowIx][groupIx] := padValue;
		end;
	end;
end;

function Evaluate(const rows: TRows; const ops: TOperations): UInt64;
var
	total, subTotal: UInt64;
	col, row: SizeInt;
	op: TOperation;
begin
	total := 0;
	for col := 0 to High(ops) do
	begin
		op := ops[col];
		if op = TOperation.Multiply then
			subTotal := 1
		else
			subTotal := 0;

		for row := 0 to High(rows) do
			case op of
				TOperation.Add:      subTotal += rows[row][col];
				TOperation.Multiply: subTotal *= rows[row][col];
			end;

		total += subTotal;
	end;
	result := total;
end;

var
	lines			: TLines;
	line			: String;
	rows1, rows2	: TRows;
	ops1, ops2		: TOperations;
	part1, part2	: UInt64;
begin
	SetLength(lines, 0);
	while not Eof(Input) do
	begin
		ReadLn(line);
		lines += [line];
	end;

	ParseNormal(lines, rows1, ops1);
	ParseCephalopod(lines, rows2, ops2);

	part1 := Evaluate(rows1, ops1);
	part2 := Evaluate(rows2, ops2);

	WriteLn('part one: ', part1);
	WriteLn('part two: ', part2);
end.
