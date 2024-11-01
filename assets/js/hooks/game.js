const GameHook = {
  mounted() {
    this.channel = null;
    this.gameId = this.el.dataset.gameId;
    
    if (this.gameId) {
      this.joinGame(this.gameId);
    }

    // Listen for local moves that need to be broadcast
    this.handleEvent("broadcast_move", ({from, to}) => {
      if (this.channel) {
        this.channel.push("move_made", { from, to });
      }
    });
  },

  joinGame(gameId) {
    if (this.channel) {
      this.channel.leave();
    }

    this.channel = window.gameSocket.channel(`game:${gameId}`);
    
    // Handle incoming moves from other player
    this.channel.on("move_made", ({from, to}) => {
      this.pushEvent("handle_remote_move", { from, to });
    });

    this.channel.join()
      .receive("ok", response => {
        console.log("Joined game successfully", response);
      })
      .receive("error", response => {
        console.error("Unable to join game", response);
      });
  },

  destroyed() {
    if (this.channel) {
      this.channel.leave();
    }
  }
};

export default GameHook;
