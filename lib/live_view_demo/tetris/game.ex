defmodule LiveViewDemo.Tetris.Game do
  alias __MODULE__
  alias LiveViewDemo.Tetris.{Tile, Shape, Board, GameConfig}

  @moduledoc
  """
  Game Logic
  Game decides move
  Game decides game_over, progress, score.
  Game decide to remove line on collission

  Game validates move left, right and to do or ignore.
  """

  @begin_offset_x 5
  @begin_offset_y 0

  defstruct [
    offset_y: 0,
    offset_x: 0,

    active_shape: nil,
    game_paused: false,
    score: 0,
    game_over: false,

    new_random: nil,

    # mode specific
    board: Board.new(),
    mode: :new,
    speed: 1000,
    shape_names: []
  ]

  alias LiveViewDemo.Tetris.{Board, Rules}

  def new(mode \\ :regular) do
    case mode do
      :regular -> GameConfig.regular_mode
      :evil -> GameConfig.evil_mode
    end
    |> new_from_config
  end

  def new_from_config(%GameConfig{ speed: speed,
                                   board_size: board_size,
                                   shape_names: shape_names,
                                   mode: mode,
                                 } = game_config) do
    %Game{
      mode: mode,
      offset_x: @begin_offset_x,
      offset_y: @begin_offset_y,
      shape_names: shape_names,
      active_shape: Shape.random_from_list(shape_names),
      # new_random: Function.capture(Shape, :random_from_list, shape_names),
      speed: speed,
      board: Board.new(board_size.x,board_size.y),
    }
  end

  # defp regular_mode_game do
  #   %Game{
  #     offset_x: @begin_offset_x,
  #     offset_y: @begin_offset_y,
  #     active_shape: new_random_shape(),
  #     speed: 600,
  #   }
  # end

  # # game settings / config
  # defp evil_mode_game do
  #   %Game{
  #     offset_x: @begin_offset_x,
  #     offset_y: @begin_offset_y,
  #     active_shape: new_evil_random_shape(),
  #     board: Board.new(20,20),
  #     speed: 400,
  #   }
  # end


  # defp new_evil_random_shape do
  #   [
  #     Shape.t_shape(),
  #     Shape.s_shape(),
  #     Shape.tree_shape(),
  #     Shape.box_shape(),
  #     Shape.l_shape(),
  #     Shape.j_shape(),
  #     Shape.u_shape(),
  #     Shape.dot_shape(),
  #     Shape.oj_shape(),
  #     Shape.z_shape()
  #   ] |> Enum.random()
  #   |> Shape.new_random(@begin_offset_x, @begin_offset_y)
  # end

  defp new_random_shape(shape_names_list \\ []) do

    # random shape comes from Shape
    # pass shape_names
    [
      Shape.t_shape(),
      Shape.s_shape(),
      Shape.box_shape(),
      Shape.l_shape(),
      Shape.j_shape(),
      Shape.oj_shape(),
      Shape.z_shape()
    ] |> Enum.random()
    |> Shape.new_random(@begin_offset_x, @begin_offset_y)
  end


  def rotate_shape(%Game{ active_shape: original_shape,
                          board: board
                        } = game) do

    step_shape = Shape.rotate(original_shape)

    shape_to_return =
    cond do
      Rules.touches_side_boundary?(board, step_shape) -> original_shape
      Rules.collides_with_board_tiles?(board, step_shape) -> original_shape
      Rules.touches_bottom_boundary?(board, step_shape) -> original_shape
      true -> step_shape
    end

    # shape_to_return =
    # if Board.tiles_present_in_board?(board, Tile.get_tiles(rotated_shape) ) do
    #   shape
    # else
    #   rotated_shape
    # end

    %Game{ game | active_shape: shape_to_return }
  end

  def move_object(%Game{board: board,
                        active_shape: original_shape,
                        shape_names: shape_names,
                        score: initial_score
                       } = game,
    move_direction) do


    next_shape = Shape.random_from_list(shape_names)

    # If below is true, declare Game Over
    if (MapSet.intersection(Tile.get_tiles(board),
          Tile.get_tiles(original_shape)) |> MapSet.size > 0
    ) do
      %Game{ game | game_over: true}
    else


    step_shape = Shape.move(original_shape, move_direction)
    # get_shape_after_move
    # next_position

    # move_direction
    # left, right
    # x-axis boundaried, move invalid
    # intersection invalid
    {board, shape} = if Enum.member?([:left, :right], move_direction)  do
      cond do
        Rules.touches_side_boundary?(board, step_shape) -> {board, original_shape}
        Rules.collides_with_board_tiles?(board, step_shape) -> {board, original_shape}
        true -> {board, step_shape}
      end

    # down
    # y-axis boundaried, drop [aftermove] and next
      # intersection, drop [aftermove] and next
    # {board, shape} = if Enum.member?([:down], move_direction)  do
    else
      # if (move_direction == :down)  do
      cond do
        Rules.touches_bottom_boundary?(board, step_shape) -> drop(board, original_shape, next_shape)
        Rules.collides_with_board_tiles?(board, step_shape) -> drop(board, original_shape, next_shape)
        true -> {board, step_shape}
      end
    end


    # tiles_and_points_after_remove_matured
    {
      tiles_after_remove_filled,
      points_scored
    } = Board.remove_filled_rows_and_move_down(board)

    %Game{game | active_shape: shape,
          board: %Board{board | filled_tiles: tiles_after_remove_filled},
          score: initial_score + points_scored
          # board: board
    }
    end
  end

  defp drop(board, shape, next_shape) do
    updated_board = Board.add_tiles(board, shape)
    # shape = new_random_shape()
    {updated_board, next_shape}
  end

  def xmove_object(%Game{board: board, active_shape: original_shape} = game,
    move_direction) do

    # shape2
    after_move = Shape.move(original_shape, move_direction)

    # shape3
    shape3 = if Rules.move_valid?(board, after_move) do
      after_move
    else
      original_shape
    end

    #shape4
    {shape4, board} = check_is_bottom_them_add_tiles(shape3, board, original_shape)

    {shape5, board} =
    if Enum.member?([:left, :right], move_direction)  do
        check_if_colliding_tile_with_board(shape4, board, original_shape)
    else
      {shape4, board}
    end

    {shape6, board} =
    if Enum.member?([:down], move_direction)  do
      check_if_colliding_tile_with_board(shape4, board, original_shape)
    else
      {original_shape, board}
    end
    # shape5

    %Game{game | active_shape: shape6, board: board}
  end

  defp check_is_bottom_them_add_tiles(%Shape{offset_y: offset_y} = shape,
    %Board{y: y, x: _x} = board,
    original_shape
  ) do
    if Rules.is_footer?(board, shape) do
      updated_board = Board.add_tiles(board, original_shape)
      shape = new_random_shape()
      {shape, updated_board}
    else
      {shape, board}
    end
  end

  defp check_if_colliding_tile_with_board(shape, board, original_shape) do
    if Rules.touches_y?(board, shape) do
      updated_board = Board.add_tiles(board, original_shape)
      shape = new_random_shape()
      {shape, updated_board}
    else
      {shape, board}
    end
  end

  def drop_shape do
  end

  def add_shape_to_board do
  end

  def collission do
  end

end
