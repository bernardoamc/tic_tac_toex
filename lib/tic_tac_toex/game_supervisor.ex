defmodule TicTacToex.GameSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_game do
    Supervisor.start_child(__MODULE__, [])
  end

  def stop_game(pid) do
    Supervisor.terminate_child(__MODULE__, pid)
  end

  def init([]) do
    children = [
      worker(TicTacToex.GameServer, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
