defmodule Machina.GameAssigner.Timeout do
  @timeout_peroid 5

  def check(waiting_players) do
    last_join_time =
      case List.last(waiting_players) do
        nil -> 0
        last_player -> last_player.join_time
      end
    age = current_time - last_join_time

    do_check(last_join_time, age)
  end

  defp do_check(last_join_time, age)
    when age > @timeout_peroid do
    {:error, :timeout_expired}
  end

  defp do_check(last_join_time, age) do
    {:ok, :waiting}
  end

  defp current_time, do: DateTime.utc_now() |> DateTime.to_unix()
end
