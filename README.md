# TicTacToex

A Tic Tac Toe written in Elixir using OTP.

To run the application locally:

  1. Install dependencies with `mix deps.get`
  2. Start Phoenix endpoint with `mix phoenix.server`
  3. Visit [`localhost:4000`](http://localhost:4000) from your browser
  4. Choose a room name and a nick.
  5. Open a new tab a repeat steps 3 and 4 (choose the same room name).
  6. Have fun!

## How it works?

Each new room is a GameState process supervised by GameSupervisor. This GameState will be stored in an Agent called GameRegistry. The GameLogic module is responsible for the game logic and is called by each GameState.
