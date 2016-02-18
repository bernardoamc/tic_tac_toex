defmodule TicTacToex.GameServer do
  @moduledoc """
  This module manages a single room.
  Each room has a state like the one in &GameLogic.init/0 module.
  """

  use GenServer
  alias TicTacToex.GameLogic

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_opts) do
    {:ok, GameLogic.init()}
  end

  def add_player(pid, player) do
    GenServer.call(pid, {:add_player, player})
  end

  def remove_player(pid, player) do
    GenServer.call(pid, {:remove_player, player})
  end

  def fetch_players(pid) do
    GenServer.call(pid, :fetch_players)
  end

  def play_at(pid, player, position) do
    GenServer.call(pid, {:play_at, player, position})
  end

  def restart(pid) do
    GenServer.call(pid, :restart_game)
  end

  def handle_call({:add_player, player}, _from, state) do
    case GameLogic.add_player(state, player) do
      {:ok, new_state} ->
        {:reply, {:ok, new_state}, new_state}
      {:error, new_state} ->
        {:reply, {:error, :full_game}, new_state}
    end
  end

  def handle_call({:play_at, player, position}, _from, state) do
    case GameLogic.play_at(state, player, position) do
      {:ok, new_state} ->
        player_attrs = Map.get(new_state, state[:turn])
        resp = {new_state[:status], state[:turn], position, player_attrs}
        {:reply, {:ok, resp}, new_state}
      {:invalid_move, state} ->
        {:reply, {:error, :invalid_move}, state}
    end
  end

  def handle_call({:remove_player, player}, _from, state) do
    {:ok, new_state} = GameLogic.remove_player(state, player)
    {:reply, {:ok, new_state}, new_state}
  end

  def handle_call(:fetch_players, _from, state) do
    resp = GameLogic.fetch_players(state)
    {:reply, resp, state}
  end

  def handle_call(:restart_game, _from, state) do
    new_state = GameLogic.restart(state)
    {:reply, :ok, new_state}
  end
end
