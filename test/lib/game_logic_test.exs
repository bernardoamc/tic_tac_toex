defmodule TicTacToex.GameLogicTest do
  use ExUnit.Case, async: true
  alias TicTacToex.GameLogic

  setup do
    {:ok, game_state} =
      GameLogic.init
      |> GameLogic.add_player("setup_player")

    {:ok, %{game: game_state}}
  end

  test "add_player/2 adds a player and update the game status", %{game: game_state} do
    {:ok, new_state} = GameLogic.add_player(game_state, "new_player")

    assert new_state[:o] == %{name: "new_player", score: 0}
    assert new_state[:status] == :running
  end

  test "add_player/2 gives and error without empty spots", %{game: game_state} do
    {:ok, new_state} = GameLogic.add_player(game_state, "new_player")
    {response, _}  = GameLogic.add_player(new_state, "full_game")

    assert response == :error
  end

  test "remove_player/2 removes the selected player and update game status", %{game: game_state} do
    {:ok, new_state} = GameLogic.add_player(game_state, "new_player")
    assert new_state[:status] == :running

    {:ok, new_state} = GameLogic.remove_player(new_state, :x)
    assert new_state[:x] == nil
    assert new_state[:status] == :waiting_player
  end

  test "play_at/2 when a player has won", %{game: game_state} do
    {:ok, game_state} = GameLogic.add_player(game_state, "new_player")

    assert Map.get(game_state[:x], :score) == 0
    assert Map.get(game_state[:o], :score) == 0

    x_to_win_state = Map.put(game_state, :board, [:x, :x, :e, :o, :e, :o, :e, :e, :e])
    x_won_state = GameLogic.play_at(x_to_win_state, "setup_player", 2)

    assert x_won_state[:status] == :won
    assert Map.get(x_won_state[:x], :score) == 1
    assert Map.get(x_won_state[:o], :score) == 0
  end

  test "play_at/2 when a draw happens", %{game: game_state} do
    {:ok, game_state} = GameLogic.add_player(game_state, "new_player")

    assert Map.get(game_state[:x], :score) == 0
    assert Map.get(game_state[:o], :score) == 0

    to_draw_state = Map.put(game_state, :board, [:x, :x, :o, :o, :o, :x, :x, :o, :e])
    draw_state = GameLogic.play_at(to_draw_state, "setup_player", 8)

    assert draw_state[:status] == :draw
    assert Map.get(draw_state[:x], :score) == 0
    assert Map.get(draw_state[:o], :score) == 0
  end

  test "play_at/2 when the game is not over", %{game: game_state} do
    {:ok, running_state} = GameLogic.add_player(game_state, "new_player")

    assert running_state[:status] == :running
    assert running_state[:turn] == :x

    new_state = GameLogic.play_at(running_state, "setup_player", 1)

    assert new_state[:status] == :running
    assert new_state[:turn] == :o
  end
end
