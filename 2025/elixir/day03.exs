defmodule Day03 do
  defmodule ListCursor do
    defstruct curr_val: nil,
              next_dgts: []
  end

  defp biggest_possible_number(desired_len, digits) do
    digits_len = length(digits)

    cond do
      desired_len == 0 ->
        []

      digits_len <= desired_len ->
        digits

      digits_len > desired_len ->
        [start_val | start_dgts] = digits

        %ListCursor{curr_val: big_val, next_dgts: remaining_dgts} =
          find_biggest_cursor(%ListCursor{
            curr_val: start_val,
            next_dgts: start_dgts
          })

        fill_length = desired_len - length(remaining_dgts) - 1

        filler =
          if(fill_length > 0) do
            biggest_possible_number(
              fill_length,
              ((Enum.reverse(digits) -- Enum.reverse(remaining_dgts)) -- [big_val])
              |> Enum.reverse()
            )
          else
            []
          end

        filler ++
          [big_val] ++
          biggest_possible_number(
            desired_len - 1,
            remaining_dgts
          )
    end
  end

  defp find_biggest_cursor(start_cursor) do
    find_biggest_cursor(start_cursor, start_cursor)
  end

  defp find_biggest_cursor(current, biggest) do
    %ListCursor{curr_val: curr_val, next_dgts: curr_next_dgts} = current
    %ListCursor{curr_val: big_val} = biggest

    if curr_val == 9 do
      current
    end

    biggest =
      if(curr_val > big_val) do
        current
      else
        biggest
      end

    case curr_next_dgts do
      [] ->
        biggest

      [new_curr_val | new_next_dgts] ->
        new = %ListCursor{
          curr_val: new_curr_val,
          next_dgts: new_next_dgts
        }

        find_biggest_cursor(
          new,
          biggest
        )
    end
  end

  defp max_joltage(batteries_turned_on) do
    File.stream!("resources/day03/input", :line)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Stream.map(&Integer.digits/1)
    |> Stream.map(&biggest_possible_number(batteries_turned_on, &1))
    |> Stream.map(&Integer.undigits/1)
    |> Enum.sum()
  end

  def first_answer do
    IO.puts("#{max_joltage(2)}")
  end

  def second_answer do
    IO.puts("#{max_joltage(12)}")
  end
end

Day03.first_answer()
Day03.second_answer()
