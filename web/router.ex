defmodule TicTacToex.Router do
  use TicTacToex.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TicTacToex do
    pipe_through :browser

    get "/", GameController, :index
    resources "/games", GameController, only: [:create, :show]
  end
end
