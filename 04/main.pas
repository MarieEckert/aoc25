{$mode objfpc}
program main;

{$scopedenums on}

uses
	Math,
	SysUtils;

type
	TTile = (Empty,ToiletPaper);
	TGrid = array of array of TTile;
	TSearchResult = record
		initial: UInt64;
		afterRemoval: UInt64;
	end;

function FindAccesible(grid: TGrid): TSearchResult;
var
	x, y, width, height	: UInt32;
	subX, subY			: Int64;
	count				: UInt8;
	found				: UInt64;

	iteration	: UInt32;
	newGrid		: TGrid;

{$ifdef logging}
	seperator: String;
{$endif}
begin
	width := Length(grid);
	height := Length(grid[0]);
	result := Default(TSearchResult);

{$ifdef logging}
	seperator := StringOfChar('-', width);
{$endif logging}

	iteration := 0;
	while True do
	begin
		found := 0;

		SetLength(newGrid, width);

{$ifdef logging}
		WriteLn('Iteration ', iteration);
{$endif}

		for x := 0 to width - 1 do
		begin
			SetLength(newGrid[x], height);

			for y := 0 to height - 1 do
			begin
				if grid[x][y] = TTile.Empty then
				begin
{$ifdef logging}
					Write('.');
{$endif}
					newGrid[x][y] := TTile.Empty;
					continue;
				end;

				count := 0;
				for subX := Max(0, x - 1) to Min(width - 1, x + 1) do
					for subY := Max(0, y - 1) to Min(height -1, y + 1) do
						if (grid[subX][subY] = TTile.ToiletPaper)
						and ((subX <> x) or (subY <> y)) then
							Inc(count);

				if count < 4 then
				begin
{$ifdef logging}
					Write(#27'[1m@'#27'[0m');
{$endif}
					Inc(found);
					newGrid[x][y] := TTile.Empty;
					continue;	
				end;

				newGrid[x][y] := TTile.ToiletPaper;
{$ifdef logging}
				Write('@');
{$endif}
			end;

{$ifdef logging}
			WriteLn;
{$endif}
		end;

{$ifdef logging}
		WriteLn(seperator);
{$endif}

		if found = 0 then break;
	
		if iteration = 0 then
			result.initial := found;

		result.afterRemoval += found;
		grid := newGrid;
		Inc(iteration);
	end;
end;

var
	line: String;
	ix: UInt32;
	grid: TGrid;
	res: TSearchResult;
begin
	SetLength(grid, 0);

	while not Eof(Input) do
	begin
		SetLength(grid, Length(grid) + 1);
		ReadLn(line);
		line := Trim(line);

		SetLength(grid[High(grid)], Length(line));
		for ix := 1 to Length(line) do
			if line[ix] = '@' then
				grid[High(grid)][ix-1] := TTile.ToiletPaper
			else
				grid[High(grid)][ix-1] := TTile.Empty;
	end;

	res := FindAccesible(grid);
	WriteLn('part one: ', res.initial);
	WriteLn('part two: ', res.afterRemoval);
end.