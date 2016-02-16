defmodule TicTacToex.GameController do
  use TicTacToex.Web, :controller
  alias TicTacToex.Game

  def index(conn, _params) do
    render conn, "index.html", changeset: Game.changeset(%TicTacToex.Game{})
  end

  def create(conn, %{"game" => game_params}) do
    changeset = Game.changeset(%TicTacToex.Game{}, game_params)

    if changeset.valid? do
      conn
        |> register_player(game_params["player"])
        |> redirect(to: game_path(conn, :show, game_params["room"]))
    else
      render(conn, "index.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    player = get_session(conn, :player)
    render(conn, "show.html", room: id, player: player)
  end

  defp register_player(conn, player_name) do
    conn
      |> put_session(:player, player_name)
      |> configure_session(renew: true)
  end
end
