defmodule Day02 do
  defp get_ids do
    File.read!("resources/day02/input")
    # trim the newline
    |> String.trim()
    # input is a csv of ranges (defined as start-end)
    |> String.split(",")
    # expand range to all contained numbers
    |> Enum.flat_map(&parse_range/1)
    # ensure at least two digits
    |> Enum.filter(&(&1 > 9))
  end

  defp parse_range(range_descriptor) do
    range_descriptor
    # split to stard and end
    |> String.split("-", parts: 2)
    # parse to ints
    |> Enum.map(&String.to_integer/1)
    # expand the range
    |> then(fn [first, second] -> first..second end)
  end

  defp decorate_unique_chunks(int, length_divisor_or_all_sizes \\ :all_sizes) do
    digits = Integer.digits(int)
    digits_len = length(digits)

    repeating_chunks =
      for chunk_size <-
            (case length_divisor_or_all_sizes do
               :all_sizes -> trunc(Float.ceil(digits_len / 2))..1//-1
               divisor -> List.wrap(trunc(Float.ceil(digits_len / divisor)))
             end), rem(digits_len, chunk_size) == 0 do
        Enum.chunk_every(digits, chunk_size)
        |> Enum.dedup()
      end
      |> Enum.filter(&(length(&1) == 1))

    {int, repeating_chunks}
  end

  def first_answer do
    get_ids()
    |> Enum.map(&decorate_unique_chunks(&1, 2))
    |> Enum.filter(&(Enum.any?(elem(&1, 1), fn unique_chunks -> length(unique_chunks) == 1 end)))
    #|> IO.inspect(charlists: :as_lists, pretty: true)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  def second_answer do
    get_ids()
    |> Enum.map(&decorate_unique_chunks(&1, :all_sizes))
    |> Enum.filter(&(Enum.any?(elem(&1, 1), fn unique_chunks -> length(unique_chunks) == 1 end)))
    #|> IO.inspect(charlists: :as_lists, pretty: true)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end
end

Day02.first_answer()
Day02.second_answer()
