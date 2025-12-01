defmodule Day01 do
  def first_answer do
    result =
      get_moves()
      |> Enum.reduce(%{:pos => 50, :zeros => 0}, fn move, acc ->
        curr_pos = rem(acc.pos + move, 100)

        %{
          :pos => curr_pos,
          :zeros =>
            acc.zeros +
              if curr_pos == 0 do
                1
              else
                0
              end
        }
      end)

    result.zeros
  end

  defmodule Day01.SecondAccumulator do
    defstruct position: 50, crossed_zero_counter: 0
  end

  alias Day01.SecondAccumulator, as: SecondAccumulator

  def second_answer do
    result =
      get_moves()
      |> Enum.reduce(%SecondAccumulator{}, fn move, acc ->
        complete_rotations = div(abs(move), 100)
        new_position = rem(100 + rem(acc.position + move, 100), 100)

        crosses_zero =
          complete_rotations +
            cond do
              rem(move, 100) > 0 && new_position < acc.position -> 1
              rem(move, 100) < 0 && acc.position == 0 -> 0
              rem(move, 100) < 0 && new_position > acc.position -> 1
              rem(move, 100) < 0 && new_position == 0 -> 1
              true -> 0
            end

        %SecondAccumulator{
          :position => new_position,
          :crossed_zero_counter => acc.crossed_zero_counter + crosses_zero
        }
      end)

    result.crossed_zero_counter
  end

  defp get_moves do
    File.stream!("resources/day01/input", :line)
    |> Stream.map(&String.trim(&1))
    |> Stream.map(&String.split_at(&1, 1))
    |> Stream.map(
      &(if "L" == elem(&1, 0) do
          -1
        else
          1
        end * (elem(&1, 1) |> String.to_integer()))
    )
    |> Enum.to_list()
  end
end
