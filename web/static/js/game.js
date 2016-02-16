let Game = {
  init(socket, element) {
    if(!element) { return }

    socket.connect()

    let roomId = element.getAttribute("data-room-id")
    let player = element.getAttribute("data-player")
    let roomChannel = socket.channel("rooms:" + roomId, { player: player })

    let cells = document.getElementsByClassName("cell");
    let board = document.getElementById("board")
    let result = document.getElementById("result");

    board.addEventListener("click", e => {
      let position = e.target.getAttribute("data-idx")
      let isEmpty = e.target.getAttribute("data-empty")
      let payload = {position: position}

      if (isEmpty === "true") {
        roomChannel.push("play_at", payload)
                  .receive("error", e => console.log(e) )
      }
    })

    result.addEventListener("click", e => {
      roomChannel.push("restart_game")
    })

    window.onbeforeunload = function () {
      roomChannel.push("remove_player");
    };

    roomChannel.on("join_game", (resp) => {
      this.setPlayers(resp)
    })

    roomChannel.on("player_left", (resp) => {
      this.removePlayer(resp)
    })

    roomChannel.on("play_at", (resp) => {
      this.playAt(cells, resp)
    })

    roomChannel.on("restart", (resp) => {
      this.restartGame(resp);
    })

    roomChannel.join()
    .receive("error", e => console.log("join failed", e))
  },

  restartGame(resp) {
    let result = document.getElementById("result");

    result.innerHTML = ""

    this.setPlayers(resp);
    this.resetBoard()
  },

  removePlayer(resp) {
    this.setPlayers(resp);
    this.resetBoard();
  },

  setPlayers(resp) {
    let players = resp.players
    let player_x = document.getElementById("player_x")
    let player_o = document.getElementById("player_o")

    player_x.innerHTML = this.generatePlayerMarkup(players.x)
    player_o.innerHTML = this.generatePlayerMarkup(players.o)
  },

  generatePlayerMarkup(player_attributes) {
    let attributes = player_attributes || {}

    attributes.name = attributes.name || "Waiting player"
    attributes.score = attributes.score || 0

    return `
    <tr>
      <td>${attributes.name}</td>
      <td>${attributes.score}</td>
    </tr>
    `
  },

  resetBoard() {
    let board = document.getElementById("board")

    board.innerHTML = `
    <div class="cell" data-idx="0" data-empty="true"></div>
    <div class="cell" data-idx="1" data-empty="true"></div>
    <div class="cell" data-idx="2" data-empty="true"></div>
    <div class="cell" data-idx="3" data-empty="true"></div>
    <div class="cell" data-idx="4" data-empty="true"></div>
    <div class="cell" data-idx="5" data-empty="true"></div>
    <div class="cell" data-idx="6" data-empty="true"></div>
    <div class="cell" data-idx="7" data-empty="true"></div>
    <div class="cell" data-idx="8" data-empty="true"></div>
    `
  },

  playAt(cells, resp) {
    let cell = cells[resp.position]
    let turn = resp.turn.toUpperCase()
    let result = document.getElementById("result")

    cell.className += ` ${resp.turn}`
    cell.setAttribute("data-empty", "false")
    cell.innerHTML = turn

    if (resp.game_status == "won") {
      let player = document.getElementById(`player_${resp.turn}`)

      player.innerHTML = this.generatePlayerMarkup(resp.player_attrs)
      result.innerHTML = `${turn} has won! Restart game?`
      result.className += ` ${resp.turn}`
    }

    if (resp.game_status == "draw") {
      result.innerHTML = "It is a draw! Restart game?"
      result.className = "info"
    }
  }
}

export default Game
