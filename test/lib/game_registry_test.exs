defmodule TicTacToex.GameRegistryTest do
  use ExUnit.Case, async: true
  alias TicTacToex.GameRegistry

  setup do
    GameRegistry.start_link(name: __MODULE__)
    {:ok, %{agent: __MODULE__}}
  end

  test "fetch/2 creates a new process if the room_id is new", %{agent: agent} do
    assert GameRegistry.find("a", agent) == :undefined

    room_pid = GameRegistry.fetch("a", agent)
    found_pid = GameRegistry.find("a", agent)

    assert room_pid == found_pid
  end

  test "fetch/2 returns a pid if the room_id already exists", %{agent: agent} do
    room_pid = GameRegistry.register("a", agent)

    assert GameRegistry.fetch("a", agent) == room_pid
  end

  test "unregister/2 removes the specified room_id from the map", %{agent: agent} do
    GameRegistry.register("a", agent)
    GameRegistry.register("b", agent)

    assert GameRegistry.registered_rooms(agent) == ["a", "b"]

    GameRegistry.unregister("a", agent)
    assert GameRegistry.registered_rooms(agent) == ["b"]
  end
end
