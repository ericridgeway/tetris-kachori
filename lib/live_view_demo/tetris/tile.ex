defmodule LiveViewDemo.Tetris.Tile do
  alias __MODULE__
  alias LiveViewDemo.Tetris.{Shape, Board}

  defstruct [x: 0,
             y: 0,
             color: "white",
             is_empty: true,
            ]

  defp tile_without_color(%Tile{} = tile) do
    %Tile{tile | color: nil}
  end

  def get_tiles(%Board{filled_tiles: tiles} = _board) do
    tiles
  end

  def get_tiles(%Shape{tiles: tiles} = _shape) do
    tiles
  end

  def filter_without_color(tiles) do
    tiles
    |> Enum.filter(fn (%Tile{is_empty: flag} = _tile) -> (flag == false) end)
    |> Enum.map(&tile_without_color(&1))
    |> MapSet.new
  end


  def shift_down(%Tile{y: y} = tile, down_count \\ 1 ) do
    %Tile{ tile | y: y + down_count}
  end

  # def tiles_from_coordinates(coordinates, tile_color) do
  #   coordinates
  #   |> Enum.reduce([], fn{x,y},
  #     acc -> [ %Tile{x: (x + offset_x),
  #                   y: (y + offset_y),
  #                   color: tile_color,
  #                   is_empty: false
  #                   } | acc]
  #   end)
  # end

  def tiles_from_shape(%Shape{
        coordinates: coordinates,
        color: color,
        offset_x: offset_x,
        offset_y: offset_y
                       } = _shape) do
    # tiles = []

    coordinates
    |> Enum.reduce([], fn{x,y},
      acc -> [ %Tile{x: (x + offset_x),
                    y: (y + offset_y),
                    color: color,
                    is_empty: false
                    } | acc]
    end)
    |> MapSet.new
  end

  def all_tile_matrix_for_shape(%Shape{coordinates: coors, length: length} = shape) do
    # for point in [1..length], do
    #   # Tile.new
    # end
  end

end
