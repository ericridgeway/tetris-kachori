defmodule LiveViewDemo.Tetris.GameConfig do
  alias __MODULE__

  defstruct [
    speed: 1000,
    board_size: %{x: 5, y: 5},
    shape_names: [],
    mode: :difficulty
  ]

  def regular_mode do
    %GameConfig{
      mode: :regular,
      speed: 600,
      board_size: %{x: 12, y: 20},
      shape_names: [
        :t_shape,
        :s_shape,
        :box_shape,
        :l_shape,
        :j_shape,
        :oj_shape,
        :z_shape
      ]
    }
  end

  def evil_mode do
    %GameConfig{
      mode: :evil,
      speed: 400,
      board_size: %{x: 20, y: 20},
      shape_names: [
        :t_shape,
        :s_shape,
        :tree_shape,
        :box_shape,
        :l_shape,
        :j_shape,
        :u_shape,
        :dot_shape,
        :oj_shape,
        :z_shape
      ]
    }
  end

end
