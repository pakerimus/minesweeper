<template>
  <div v-loading="loading">
    <div v-if="game.id" >
      <el-page-header @back="goBack" :content="title" />
      <div class="page-content">
        {{ game }}
        <hr>
        {{ cells }}
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "Game",
  props: {
    userId: {
      type: Number,
      required: true
    },
    gameId: {
      type: Number,
      required: true
    }
  },
  data: function () {
    return {
      loading: false,
      gameState: null,
      game: {
        id: null
      },
      cells: []
    }
  },
  computed: {
    title() {
      return `Game #${this.game.id}`
    }
  },
  created() {
    this.getGame();
  },
  methods: {
    getGame() {
      this.loading = true;
      this.$http.get(`/api/users/${this.userId}/games/${this.gameId}`)
        .then(response => {
          console.log("game response", response.body);
          this.game = response.body.game;
          this.cells = response.body.cells;
        })
        .catch(error => {
          console.log("game error", error);
          this.$alert(error.body.error, 'Error',  { confirmButtonText: 'OK' });
        })
        .finally(() => {
          this.loading = false;
        });
    },
    goBack() {
      if (this.gameState == "started") this.sendGameAction("pause");
      this.$emit('clearGame');
    },
    sendGameAction(action) {
      console.log("sendGameAction", action);
    },
    refreshCells() {
      this.loading = true;
      this.$http.get(`/api/users/${this.userId}/games/${this.game.id}/cells`)
        .then(response => {
          console.log("cells response", response.body);
          this.cells = response.body.cells;
        })
        .catch(error => {
          console.log("cells error", error);
          this.$alert(error.body.error, 'Error',  { confirmButtonText: 'OK' });
        })
        .finally(() => {
          this.loading = false;
        });
    }
  }
}
</script>
