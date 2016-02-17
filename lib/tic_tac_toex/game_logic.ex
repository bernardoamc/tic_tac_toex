defmodule TicTacToex.GameLogic do
  def init do
    %{
      board: [:e, :e, :e, :e, :e, :e, :e, :e, :e],
      x: nil,
      o: nil,
      turn: :x,
      status: :waiting_player
    }
  end

  def play_at(state, player, position) do
    if valid_move?(state, player, position) do
      new_state = fill_board(state, position)
      {:ok, adjust_game_state(new_state, terminal?(new_state[:board]))}
    else
      {:invalid_move, state}
    end
  end

  def add_player(state, player) do
    case fetch_empty_spot(state) do
      {:empty, false} ->
        {:error, state}

      {:empty, spot}  ->
        state =
          state
          |> Map.put(spot, %{name: player, score: 0})
          |> update_player_status

        {:ok, state}
    end
  end

  def remove_player(state, player) do
    state =
      state
      |> fetch_and_clear(player)
      |> reset_board
      |> Map.put(:turn, :x)

    {:ok, state}
  end

  def restart(state) do
    state
      |> reset_board
      |> switch_players
      |> Map.put(:turn, :x)
      |> Map.put(:status, :running)
  end

  def fetch_players(%{x: nil, o: nil} = state) do
    {:empty, []}
  end

  def fetch_players(%{x: player_x, o: player_o} = state) do
    {:ok, %{x: player_x, o: player_o}}
  end

  defp valid_move?(state, player, position) do
    player_attributes = Map.get(state, state[:turn])

    same_player = player_attributes[:name] == player
    empty_cell  = Enum.at(state[:board], position) == :e
    game_running = state[:status] == :running

    same_player && empty_cell && game_running
  end

  defp fill_board(state, position) do
    new_board = List.replace_at(state[:board], position, state[:turn])
    Map.put(state, :board, new_board)
  end

  defp adjust_game_state(state, {:won, player}) do
    state
      |> increment_score(player)
      |> Map.put(:status, :won)
  end

  defp adjust_game_state(state, {:draw, true}) do
    state
      |> Map.put(:status, :draw)
  end

  defp adjust_game_state(state, {:draw, false}) do
    state
      |> next_turn
  end

  defp fetch_empty_spot(state) do
    cond do
      is_nil(state[:x]) -> {:empty, :x}
      is_nil(state[:o]) -> {:empty, :o}
      true -> {:empty, false}
    end
  end

  # Rows
  defp terminal?([:x, :x, :x, _, _, _, _, _, _]), do: {:won, :x}
  defp terminal?([_, _, _, :x, :x, :x, _, _, _]), do: {:won, :x}
  defp terminal?([_, _, _, _, _, _, :x, :x, :x]), do: {:won, :x}
  defp terminal?([:o, :o, :o, _, _, _, _, _, _]), do: {:won, :o}
  defp terminal?([_, _, _, :o, :o, :o, _, _, _]), do: {:won, :o}
  defp terminal?([_, _, _, _, _, _, :o, :o, :o]), do: {:won, :o}

  # Columns
  defp terminal?([:x, _, _, :x, _, _, :x, _, _]), do: {:won, :x}
  defp terminal?([_, :x, _, _, :x, _, _, :x, _]), do: {:won, :x}
  defp terminal?([_, _, :x, _, _, :x, _, _, :x]), do: {:won, :x}
  defp terminal?([:o, _, _, :o, _, _, :o, _, _]), do: {:won, :o}
  defp terminal?([_, :o, _, _, :o, _, _, :o, _]), do: {:won, :o}
  defp terminal?([_, _, :o, _, _, :o, _, _, :o]), do: {:won, :o}

  # Diagonals
  defp terminal?([:x, _, _, _, :x, _, _, _, :x]), do: {:won, :x}
  defp terminal?([_, _, :x, _, :x, _, :x, _, _]), do: {:won, :x}
  defp terminal?([:o, _, _, _, :o, _, _, _, :o]), do: {:won, :o}
  defp terminal?([_, _, :o, _, :o, _, :o, _, _]), do: {:won, :o}

  # Draw
  defp terminal?(board), do: {:draw, Enum.all?(board, &(&1 != :e))}

  defp next_turn(state) do
    if state[:turn] == :x do
      Map.put(state, :turn, :o)
    else
      Map.put(state, :turn, :x)
    end
  end

  defp increment_score(state, player) do
    attributes =
      state
      |> Map.get(player)
      |> Map.update!(:score, &(&1 + 1))

    Map.put(state, player, attributes)
  end

  defp reset_board(state) do
    Map.put(state, :board, [:e, :e, :e, :e, :e, :e, :e, :e, :e])
  end

  defp switch_players(%{x: player_x, o: player_o} = state) do
    state
      |> Map.put(:x, player_o)
      |> Map.put(:o, player_x)
  end

  defp fetch_and_clear(%{x: %{name: player}} = state, player) do
    state
      |> Map.put(:x, nil)
      |> update_player_status
  end

  defp fetch_and_clear(%{o: %{name: player}} = state, player) do
    state
      |> Map.put(:o, nil)
      |> update_player_status
  end

  defp fetch_and_clear(state, _player), do: state

  defp update_player_status(state) do
    cond do
      state[:x] && state[:o] -> Map.put(state, :status, :running)
      state[:x] || state[:o] -> Map.put(state, :status, :waiting_player)
      true -> Map.put(state, :status, :no_players)
    end
  end
end
