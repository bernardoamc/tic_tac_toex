defmodule TicTacToex.Channels.RoomChannelTest do
  use TicTacToex.ChannelCase

  setup do
    {:ok, socket} = connect(TicTacToex.UserSocket, %{})

    {:ok, socket: socket}
  end

  test "join/3", %{socket: socket} do
    room = "join"
    {:ok, _reply, socket} = subscribe_and_join(socket, "rooms:#{room}", %{"player" => "setup" })

    assert socket.assigns.room_id == room
    assert socket.assigns.player == "setup"
    assert_broadcast "join_game", %{players: %{o: nil, x: %{name: "setup", score: 0}} }
  end

  test "remove_player with remaining players in game", %{socket: socket} do
    room = "remove_player_remaining"
    {:ok, _, socket_1} = subscribe_and_join(socket, "rooms:#{room}", %{"player" => "player_1" })
    {:ok, _, socket_2} = subscribe_and_join(socket, "rooms:#{room}", %{"player" => "player_2" })

    push socket_2, "remove_player", %{}

    assert TicTacToex.GameRegistry.find(room) != :undefined
    assert_broadcast "player_left", %{players: %{o: nil, x: %{name: "player_1", score: 0}}}
  end

  test "remove_player without remaining players", %{socket: socket} do
    room = "remove_player_none"
    {:ok, _, socket} = subscribe_and_join(socket, "rooms:#{room}", %{"player" => "player_1" })

    push socket, "remove_player", %{}
    refute_broadcast "player_left", %{players: []}
    assert TicTacToex.GameRegistry.find(room) == :undefined
  end

  test "play_at with valid move", %{socket: socket} do
    room = "play_at_valid"
    position = "0"
    {:ok, _, socket_1} = subscribe_and_join(socket, "rooms:#{room}", %{"player" => "player_1" })
    {:ok, _, socket_2} = subscribe_and_join(socket, "rooms:#{room}", %{"player" => "player_2" })

    push socket_1, "play_at", %{"position" => position}

    broadcast_response =  %{
      turn: :x,
      position: 0,
      game_status: :running,
      player_attrs: %{name: "player_1", score: 0}
    }

    assert_broadcast "play_at", broadcast_response
  end

  test "play_at with invalid move", %{socket: socket} do
    room = "play_at_invalid"
    position = "0"
    {:ok, _reply, socket_1} = subscribe_and_join(socket, "rooms:#{room}", %{"player" => "player_1" })
    {:ok, _reply, socket_2} = subscribe_and_join(socket, "rooms:#{room}", %{"player" => "player_2" })

    ref = push socket_2, "play_at", %{"position" => position}

    assert_reply ref, :error, %{reason: :invalid_move}
  end

  test "restart_game", %{socket: socket} do
    room = "restart_game"
    {:ok, _, socket} = subscribe_and_join(socket, "rooms:#{room}", %{"player" => "player_1" })

    push socket, "restart_game", %{}
    assert_broadcast "restart", %{players: %{x: nil, o: %{name: "player_1", score: 0}}}
  end
end
