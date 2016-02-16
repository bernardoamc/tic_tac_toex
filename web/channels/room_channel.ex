defmodule TicTacToex.RoomChannel do
  use Phoenix.Channel

  def join("rooms:" <> room_id, %{"player" => player}, socket) do
    pid = TicTacToex.GameRegistry.fetch(room_id)

    socket =
      socket
      |> assign(:pid, pid)
      |> assign(:player, player)
      |> assign(:room_id, room_id)

    case TicTacToex.GameServer.add_player(pid, player) do
      {:ok, _state} ->
        send(self, :player_joined)
        {:ok, socket}
      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end

  def handle_info(:player_joined, socket) do
    pid = socket.assigns.pid
    {:ok, players} = TicTacToex.GameServer.fetch_players(pid)

    broadcast! socket, "join_game", %{players: players}

    {:noreply, socket}
  end

  def handle_in("remove_player", _params, socket) do
    pid = socket.assigns.pid
    player = socket.assigns.player

    {:ok, _state} = TicTacToex.GameServer.remove_player(pid, player)

    case TicTacToex.GameServer.fetch_players(pid) do
      {:ok, players} ->
        broadcast! socket, "player_left", %{players: players}
      {:empty, _} ->
        TicTacToex.GameRegistry.unregister(socket.assigns.room_id)
    end

    {:noreply, socket}
  end

  def handle_in("play_at", %{"position" => position}, socket) do
    pid = socket.assigns.pid
    player = socket.assigns.player
    position = String.to_integer(position)

    case TicTacToex.GameServer.play_at(pid, player, position) do
      {:ok, {game_status, turn, position, player_attrs}} ->
        resp = %{turn: turn, position: position, game_status: game_status, player_attrs: player_attrs}
        broadcast! socket, "play_at", resp
        {:reply, :ok, socket}
      {:error, reason} ->
        {:reply, {:error, %{reason: reason}}, socket}
    end
  end

  def handle_in("restart_game", _, socket) do
    pid = socket.assigns.pid
    :ok = TicTacToex.GameServer.restart(pid)
    {:ok, players} = TicTacToex.GameServer.fetch_players(pid)

    broadcast! socket, "restart", %{players: players}

    {:noreply, socket}
  end
end
