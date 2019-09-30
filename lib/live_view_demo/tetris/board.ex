defmodule LiveViewDemo.Tetris.Board do
  alias __MODULE__
  alias LiveViewDemo.Tetris.{Shape, Tile}

  defstruct [
    x: 12,
    y: 20,
    filled_tiles: MapSet.new(),
    bottom_tiles: []
  ]

  def new(x \\ 12, y \\ 20) do
    create_new_empty_board_of_dimension(x, y)
  end

  def tiles_present_in_board?(%Board{filled_tiles: filled_tiles} = _board,
    tiles_to_check) do
    intr = MapSet.intersection(
      Tile.filter_without_color(filled_tiles),
      Tile.filter_without_color(tiles_to_check)
    )

    IO.puts inspect(intr)

    MapSet.size(intr) > 0
  end


  defp create_new_empty_board_of_dimension(x, y) do
    %Board{
      x: x,
      y: y
    }
  end

  def add_tiles(%Board{filled_tiles: filled_tiles} = board,
    %Shape{tiles: tiles} = _shape) do

    # IO.puts inspect(MapSet.intersection(filled_tiles, tiles))
    # sign of GameOver

    %Board{ board | filled_tiles:
            MapSet.new(
              List.flatten(
                MapSet.to_list(tiles),
                MapSet.to_list(filled_tiles)
              )
            )
    }
  end

  def filled_row_tiles(
    %Board{
      filled_tiles: tiles,
      x: x,
      y: _y
    } = _board) do

    coords = tiles
    |> Enum.map(fn(tile) -> {tile.x, tile.y} end)
    |> Enum.group_by(fn({x,y}) -> y end)
    |> Enum.to_list
    |> Enum.filter(fn{k,v} -> length(v) == x end)
    |> Enum.map(fn({k,v}) -> v end)
    |> List.flatten

    fill_tiles = tiles
    |> Enum.filter(fn(tile) -> Enum.member?(coords, {tile.x, tile.y}) end)

    # row_numbers of filled in board
  end

  def remove_filled_rows_and_move_down(%Board{
        filled_tiles: tiles,
        x: board_x} = board) do

    rows_numbers = get_filled_row_numbers(tiles, board_x)

    points_earned = length(rows_numbers) * board_x

    final_tiles = tiles
    |> tiles_after_remove_matured_rows(rows_numbers)
    |> bring_down_above_tiles(rows_numbers)
    |> MapSet.new

    {final_tiles, points_earned}
  end

  def bring_down_above_tiles(tiles, []) do
    tiles
  end
  def bring_down_above_tiles(tiles, row_numbers) do
    tiles
    |> Enum.map(fn(tile) ->
      offset = Enum.count(row_numbers, fn y -> (y > tile.y) end)
      Tile.shift_down(tile, offset)
    end)
  end

  defp tiles_after_remove_matured_rows(tiles, rows_numbers) do
    tiles
    |> Enum.filter(fn(tile) -> !Enum.member?(rows_numbers, tile.y) end)
  end

  defp get_filled_row_numbers(tiles, board_x) do
    tiles
    |> Enum.map(fn(tile) -> {tile.x, tile.y} end)
    |> Enum.group_by(fn({x,y}) -> y end)
    |> Enum.to_list
    |> Enum.filter(fn{k,v} -> length(v) == board_x end)
    |> Enum.map(fn({row_number, _tiles}) -> row_number end)
    |> List.flatten
  end


  def add_bottom_tiles(_board) do
  end

end
