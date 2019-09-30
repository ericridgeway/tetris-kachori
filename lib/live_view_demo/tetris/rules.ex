defmodule LiveViewDemo.Tetris.Rules do
  alias LiveViewDemo.Tetris.{Shape, Board, Tile}


  # LHS or RHS boundary
  def touches_side_boundary?(
    %Board{x: board_x, y: _y, filled_tiles: filled_tiles} = _board,
    %Shape{
      offset_x: offset_x,
      offset_y: _offset_y,
      tiles: _shape_tiles,
      length: _shape_length,
      coordinates: coordinates
    } = _shape) do

    cond do
      # offset_x < 0 -> true
      Enum.any?(coordinates, fn({x,y}) -> (x + offset_x) == 0 end) -> true
      Enum.any?(coordinates, fn({x,y}) -> (x + offset_x) == (board_x + 1) end) -> true
      # offset_x > (board_x - shape_length) -> true
      # offset_x == x -> true
      true -> false
    end
  end

  def touches_bottom_boundary?(
    %Board{x: _x, y: board_y, filled_tiles: _filled_tiles} = _board,
    %Shape{
      offset_x: _offset_x,
      offset_y: offset_y,
      coordinates: coordinates,
      tiles: _shape_tiles,
      length: _shape_length
    } = _shape) do

    Enum.any?(coordinates, fn({x,y}) -> ((y + offset_y ) == (board_y + 1 )) end)
    # offset_y > (y - 1)
  end

  def collides_with_board_tiles?(
    %Board{filled_tiles: filled_tiles},
    %Shape{tiles: shape_tiles}
  ) do

    MapSet.intersection(
      Tile.filter_without_color(filled_tiles),
      Tile.filter_without_color(shape_tiles)
    )
    |> MapSet.size() > 0
  end

  def move_valid?(%Board{x: x, y: _y, filled_tiles: filled_tiles} = _board \\ [],
    %Shape{
      offset_x: offset_x,
      offset_y: _offset_y,
      tiles: shape_tiles,
      length: shape_length
    } = _shape) do

    intr = MapSet.intersection(
      Tile.filter_without_color(filled_tiles),
      Tile.filter_without_color(shape_tiles)
    )

    cond do
      offset_x < 0 -> false
      offset_x > (x - shape_length) -> false
     # offset_y > (y - 1) -> false
      offset_x == x -> true
      MapSet.size(intr) > 0 -> false
      true -> true
    end

  end

  def is_footer?(%Board{x: _x, y: y} = _board \\ [],
    %Shape{
      offset_x: _offset_x,
      offset_y: offset_y,
      length: shape_length
    } = _shape) do
    offset_y > (y - shape_length)
  end

  def touches_y?(
    %Board{
      filled_tiles: filled_tiles,
      # bottom_tiles: bottom_tiles
    } = _board,
    %Shape{tiles: shape_tiles} = _shape) do

    intr = MapSet.intersection(
      Tile.filter_without_color(filled_tiles),
      Tile.filter_without_color(shape_tiles)
    )

    MapSet.size(intr) > 0
  end

  def check_collission do
  end

end

