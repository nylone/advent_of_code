defmodule Day04 do
  @input_path "resources/day04/input"

  defmodule Matrix do
    @enforce_keys [:cells, :size]
    defstruct [:cells, :size]
  end

  @spec load_matrix :: Matrix
  defp load_matrix do
    {:ok, matrix} = File.read(@input_path)
    matrix = String.replace(matrix, ~r"\s", "")
    side_size = :math.sqrt(byte_size(matrix))
    side_size = trunc(side_size)
    %Matrix{cells: matrix, size: side_size}
  end

  @spec outside_bounds(integer(), integer()) :: boolean()
  defguardp outside_bounds(side_size, rel_pos) when rel_pos < 0 or rel_pos >= side_size

  @spec cell_at_pos(Matrix, integer(), integer()) :: byte()
  defp cell_at_pos(matrix, x, y) do
    cond do
      outside_bounds(matrix.size, x) -> nil
      outside_bounds(matrix.size, y) -> nil
      true -> :binary.at(matrix.cells, x + y * matrix.size)
    end
  end

  @spec cell_at_pos(Matrix, integer(), integer(), integer(), integer()) :: byte()
  defp cell_at_pos(matrix, x, y, x_delta, y_delta) do
    cell_at_pos(matrix, x + x_delta, y + y_delta)
  end

  @adjacent_deltas [
    {1, 1},
    {1, 0},
    {1, -1},
    {0, 1},
    {0, -1},
    {-1, 1},
    {-1, 0},
    {-1, -1}
  ]

  @roll_of_paper ?@

  @spec count_adjacents(Matrix, integer(), integer()) :: integer()
  defp count_adjacents(matrix, x, y) do
    get_cell = fn {x_delta, y_delta} ->
      cell_at_pos(matrix, x, y, x_delta, y_delta)
    end

    @adjacent_deltas
    |> Enum.map(&get_cell.(&1))
    # |> IO.inspect(label: "X -> #{x} and Y -> #{y}, adjacents", charlists: :as_lists)
    |> Enum.filter(&(&1 === @roll_of_paper))
    |> Enum.count()

    # |> IO.inspect(label: "X -> #{x} and Y -> #{y}, sum", charlists: :as_lists)
  end

  @spec count_all_removable_rolls(Matrix) :: integer()
  defp count_all_removable_rolls(matrix) do
    remove_rolls({matrix, 0})
  end

  @spec remove_rolls({Matrix, integer()}) :: integer()
  defp remove_rolls({matrix, accumulator_removed}) when is_struct(matrix, Matrix) do
    {bytes_list, accumulator_list} =
      for pos <- 0..((matrix.size |> :math.pow(2) |> trunc()) - 1) do
        x = rem(pos, matrix.size)
        y = div(pos, matrix.size)
        cell_value = cell_at_pos(matrix, x, y)
        can_be_removed = count_adjacents(matrix, x, y) < 4

        IO.inspect({x, y}, label: "{x, y}")
        IO.inspect(cell_value, label: "cell")
        IO.inspect(can_be_removed, label: "cbr")

        case {cell_value, can_be_removed} do
          {@roll_of_paper, true} -> {?., 1}
          {nil, _} -> {?., 0}
          {cell_value, _} -> {cell_value, 0}
        end
      end
      |> Enum.unzip()

    new_matrix =
      bytes_list
      |> Enum.map(&<<&1>>)
      |> Enum.reduce(&<>/2)

    removed_rolls = Enum.sum(accumulator_list)
    IO.inspect(removed_rolls, label: "removed rolls")
    IO.inspect(accumulator_removed, label: "accumulator removed rolls")

    case removed_rolls do
      0 ->
        accumulator_removed

      _ ->
        remove_rolls({%{matrix | cells: new_matrix}, accumulator_removed + removed_rolls})
    end
  end

  def first_answer do
    matrix = load_matrix()
    total_cells = trunc(:math.pow(matrix.size, 2))

    for pos <- 0..total_cells do
      x = rem(pos, matrix.size)
      y = div(pos, matrix.size)
      cell_at_pos(matrix, x, y) === @roll_of_paper && count_adjacents(matrix, x, y) < 4
    end
    |> Enum.filter(&(!!&1))
    |> Enum.count()
    |> IO.inspect(label: "Count of reachable rolls")
  end

  def second_answer do
    matrix = load_matrix()

    count_all_removable_rolls(matrix)
    |> IO.inspect(label: "total removable rolls")
  end
end

Day04.first_answer()
Day04.second_answer()
