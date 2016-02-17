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

  test "remove_player/2 removes the selected player and update game state", %{game: game_state} do
    {:ok, new_state} = GameLogic.add_player(game_state, "new_player")
    assert new_state[:status] == :running

    {:ok, new_state} = GameLogic.remove_player(new_state, "new_player")
    assert new_state[:o] == nil
    assert new_state[:board] == [:e, :e, :e, :e, :e, :e, :e, :e, :e]
    assert new_state[:turn] == :x
    assert new_state[:status] == :waiting_player
  end

  test "play_at/3 when a player has won", %{game: game_state} do
    {:ok, game_state} = GameLogic.add_player(game_state, "new_player")

    assert Map.get(game_state[:x], :score) == 0
    assert Map.get(game_state[:o], :score) == 0

    x_to_win_state = Map.put(game_state, :board, [:x, :x, :e, :o, :e, :o, :e, :e, :e])
    {:ok, x_won_state} = GameLogic.play_at(x_to_win_state, "setup_player", 2)

    assert x_won_state[:status] == :won
    assert Map.get(x_won_state[:x], :score) == 1
    assert Map.get(x_won_state[:o], :score) == 0
  end

  test "play_at/3 when a draw happens", %{game: game_state} do
    {:ok, game_state} = GameLogic.add_player(game_state, "new_player")

    assert Map.get(game_state[:x], :score) == 0
    assert Map.get(game_state[:o], :score) == 0

    to_draw_state = Map.put(game_state, :board, [:x, :x, :o, :o, :o, :x, :x, :o, :e])
    {:ok, draw_state} = GameLogic.play_at(to_draw_state, "setup_player", 8)

    assert draw_state[:status] == :draw
    assert Map.get(draw_state[:x], :score) == 0
    assert Map.get(draw_state[:o], :score) == 0
  end

  test "play_at/3 when the game is not over", %{game: game_state} do
    {:ok, running_state} = GameLogic.add_player(game_state, "new_player")

    assert running_state[:status] == :running
    assert running_state[:turn] == :x

    {:ok, new_state} = GameLogic.play_at(running_state, "setup_player", 1)

    assert new_state[:status] == :running
    assert new_state[:turn] == :o
  end

  test "play_at/2 when the move is invalid", %{game: game_state} do
    {:ok, running_state} = GameLogic.add_player(game_state, "new_player")

    assert running_state[:status] == :running
    assert running_state[:turn] == :x

    {response, new_state} = GameLogic.play_at(running_state, "new_player", 1)

    assert response == :invalid_move
    assert new_state[:board] == [:e, :e, :e, :e, :e, :e, :e, :e, :e]
    assert new_state[:status] == :running
    assert new_state[:turn] == :x
  end

  test "restart/1 switch players and reset board", %{game: game_state} do
    {:ok, game_state} = GameLogic.add_player(game_state, "new_player")

    random_state =
      game_state
      |> Map.put(:board, [:x, :x, :e, :o, :e, :o, :e, :e, :e])
      |> Map.put(:turn, :o)

    assert random_state[:x] == %{name: "setup_player", score: 0}
    assert random_state[:o] == %{name: "new_player", score: 0}

    restart_state = GameLogic.restart(random_state)

    assert restart_state[:x] == %{name: "new_player", score: 0}
    assert restart_state[:o] == %{name: "setup_player", score: 0}
    assert restart_state[:board] == [:e, :e, :e, :e, :e, :e, :e, :e, :e]
    assert restart_state[:turn] == :x
  end

  test "fetch_players/1 when there is no players", %{game: game_state} do
    game_state = Map.put(game_state, :x, nil)

    {status, players} = GameLogic.fetch_players(game_state)

    assert status == :empty
    assert players == []
  end

  test "fetch_players/1 when players exist", %{game: game_state} do
    {:ok, game_state} = GameLogic.add_player(game_state, "new_player")

    {status, players} = GameLogic.fetch_players(game_state)

    assert status == :ok
    assert players == %{o: %{name: "new_player", score: 0}, x: %{name: "setup_player", score: 0}}
  end
end
