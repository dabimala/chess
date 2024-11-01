let GameHook = {
  mounted() {
    this.setupGame()
  },

  setupGame() {
    const gameId = this.el.dataset.gameId
    this.channel = window.socket.channel(`game:${gameId}`)

    this.channel.join()
      .receive("ok", response => {
        console.log("Joined game channel successfully", response)
      })
      .receive("error", response => {
        console.log("Unable to join game channel", response)
      })

    this.channel.on("move_made", payload => {
      this.handleRemoteMove(payload)
    })

    this.channel.on("player_joined", payload => {
      console.log("Player joined:", payload)
    })
  },

  handleRemoteMove(payload) {
    // Convert arrays back to the format expected by the LiveView
    this.pushEvent("remote_move", {
      from: payload.from,
      to: payload.to,
      player: payload.player
    })
  },

  handleEvent("make_move", payload => {
    this.channel.push("make_move", {
      from: payload.from,
      to: payload.to,
      player: payload.player
    })
  }),

  destroyed() {
    if (this.channel) {
      this.channel.leave()
    }
  }
}

export default GameHook
