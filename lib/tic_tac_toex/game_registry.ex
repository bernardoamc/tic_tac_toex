defmodule TicTacToex.GameRegistry do
  @name __MODULE__

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, @name)
    Agent.start_link(fn -> Map.new end, opts)
  end

  def fetch(room_id, agent_name \\ @name) do
    case find(room_id, agent_name) do
      :undefined -> register(room_id, agent_name)
      pid -> pid
    end
  end

  def find(room_id, agent_name \\ @name) do
    Agent.get(agent_name, &Map.get(&1, room_id, :undefined))
  end

  def unregister(room_id, agent_name \\ @name) do
    pid = find(room_id, agent_name)

    if (pid != :undefined) do
      TicTacToex.GameSupervisor.stop_game(pid)
      Agent.update(agent_name, &Map.delete(&1, room_id))
    end
  end

  def registered_rooms(agent_name \\ @name) do
    Agent.get(agent_name, &Map.keys(&1))
  end

  def register(room_id, agent_name \\ @name) do
    {:ok, pid} = TicTacToex.GameSupervisor.start_game
    Agent.update(agent_name, &Map.put_new(&1, room_id, pid))

    pid
  end
end
