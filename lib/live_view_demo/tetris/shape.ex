defmodule LiveViewDemo.Tetris.Shape do
  alias __MODULE__
  alias LiveViewDemo.Tetris.{Tile}

  # use MapSet for tiles
  # MapSet makes possible to find intersection and diffs
  # only co-ordinates of tile. type to filter
  defstruct [color: "red",
             coordinates: [],
             length: 0,
             offset_x: 6,
             offset_y: 0,
             # points: MapSet.new(),
             tiles: MapSet.new()
            ]

  def new(offset_x \\ 6, offset_y \\ 0) do
    %Shape{offset_x: offset_x, offset_y: offset_y}
  end

  def random_from_list(shape_names) do
    random_shape_name = Enum.random(shape_names)
    shape = Function.capture(Shape, random_shape_name, 0).()

    %Shape{
      shape |
      tiles: Tile.tiles_from_shape(shape)
    }
  end

  def new_random(%Shape{coordinates: shape_coordinates} = shape \\ t_shape(),
    offset_x \\ 6, offset_y \\ 0) do
    %Shape{shape |
           offset_x: offset_x,
           offset_y: offset_y,
           # tiles: MapSet.new(Tile.tiles_from_shape(shape))
           tiles: Tile.tiles_from_shape(shape)
    }
  end

  def move(%Shape{offset_x: offset_x, offset_y: offset_y} =  shape, direction) do
    # move each tile coordinate
    shape = case direction do
              :left -> %Shape{shape |offset_y: offset_y, offset_x: offset_x - 1 }
              :right -> %Shape{shape |offset_y: offset_y, offset_x: offset_x + 1 }
              :down -> %Shape{shape |offset_y: offset_y + 1, offset_x: offset_x }
            end
    # %{shape | tiles: Tile.tiles_from_shape(shape)}
    # %Shape{shape | tiles: MapSet.put(shape.tiles, Tile.tiles_from_shape(shape)) }
    %Shape{shape | tiles: MapSet.new(
              # MapSet.to_list(shape.tiles),
              Tile.tiles_from_shape(shape)
            )
    }
  end

  def rotate(%Shape{
        tiles: tiles,
        length: length,
        coordinates: coordinates,
        color: color
             } = shape) do

    new_coords = coordinates
    |> Enum.map(fn{x, y} -> {length - y, x} end)

    rotated_shape =
      %Shape{
        shape | coordinates: new_coords
      }

    %Shape{rotated_shape | tiles: Tile.tiles_from_shape(rotated_shape)}

  end

  # t t t
  # * t *
  # * * *

  # 11 21 31
  # 12 22 32
  # 13 23 33

  def t_shape do
    %Shape{
      color: "blue",
      length: 3,
      coordinates: [{1,1}, {2,1}, {3,1}, {2,2}],
    }
  end

  # u u u
  # u * u
  # * * *

  # 11 21 31
  # 12 22 32
  # 13 23 33

  def u_shape do
    %Shape{
      color: "white",
      length: 3,
      coordinates: [{1,1}, {2,1}, {3,1},
                    {1,2},{3,2}
                   ],
    }
  end

  # dot

  # 11

  def dot_shape do
    %Shape{
      color: "white",
      length: 1,
      coordinates: [{1,1}],
    }
  end

  # * * s * *
  # * s s s *
  # s s s s s
  # s s s s s
  # * * s * *

  # 11 21 31 41 51
  # 12 22 32 42 52
  # 13 23 33 43 53
  # 14 24 34 44 54
  # 15 25 35 45 55

  def tree_shape do
    %Shape{
      color: "grey",
      length: 5,
      coordinates: [{3, 1},
                    {3,2}, {2,2}, {4,2},
                    {1,3},{2,3},{3,3},{4,3},{5,3},
                    {1,4},{2,4},{3,4},{4,4},{5,4},
                    {3,5}
                   ],
    }
  end



  # z z *
  # * z z
  # * * *
  def z_shape do
    %Shape{
      color: "green",
      length: 3,
      coordinates: [{1,1}, {2,1}, {2,2}, {3,2}]
    }
  end

  # * s s
  # s s *
  # * * *
  def s_shape do
    %Shape{
      color: "orange",
      length: 3,
      coordinates: [{2,1}, {3,1}, {1,2}, {2,2}]
    }
  end

  # * l * *
  # * l * *
  # * l * *
  # * l * *
  def l_shape do
    %Shape{
      color: "red",
      length: 4,
      coordinates: [{2,1}, {2,2}, {2,3}, {2,4}]
    }
  end

  # * j *
  # * j *
  # j j *
  def j_shape do
    %Shape{
      color: "purple",
      length: 3,
      coordinates: [{2,1}, {2,2}, {2,3}, {1,3}]
    }
  end

  # * j *
  # * j *
  # * j j
  def oj_shape(offset_x \\ 0, offset_y \\ 0) do
    %Shape{
      color: "blue",
      length: 3,
      coordinates: [{ 2,1}, {2,2}, {2,3}, {3,3}]
    }
  end

  def add_offset(%Shape{coordinates: coor} = shape, offset_x \\ 0, offset_y \\0) do
    coords= Enum.map(coor, fn({x,y}) -> {x + offset_x, y + offset_y} end)
    %Shape{shape | coordinates: coords}
  end

  def box_shape do
    %Shape{
      color: "yellow",
      length: 2,
      coordinates: [{1,1}, {2,1}, {1,2}, {2,2}]
    }
  end

  def dice do
    # [{[0,0,0], 1},{[1,1,1], 2},{[0,1,1], 3}]
    [[0,1,0],[0,1,0],[0,1,1]]
    # Tabela.Shape.dice |> Enum.with_index(1) |> Enum.map(fn({arr, index}) -> arr  end)
  end

  # * j *  - * * j - * j *
  # * j *  - j j j - * j *
  # j j *  - * * * - j j *
  def xrotate(%Shape{coordinates: coor} = shape) do
    # coor = coordinates |> Enum.map(&Tuple.to_list(&1))
    # %Shape{shape |  coordinates: coor}

    # IO.puts inspect(coor)

    # shp = [{[0,0,0], 1},{[1,1,1], 2},{[0,1,1], 3}]
    # want = {2,1}, {2,2},{2,3},{3,3}

    # gr = graph
    # |> Enum.map(&Tuple.to_list(&1))
    # |> Enum.zip
    # |> Enum.map(&Tuple.to_list(&1) )

    # rotated = coor
    # |> Enum.map(&Tuple.to_list(&1))
    # |> Enum.zip
    # |> Enum.map(&Tuple.to_list(&1))
    # |> List.flatten
    # |> Enum.chunk_every(2)
    # |> Enum.map(&List.to_tuple(&1))


    rotated = coor
    |> Enum.map(fn({x,y}) -> {y,x} end)

    # IO.puts inspect(rotated)

    %Shape{shape | coordinates: rotated}
  end

end
