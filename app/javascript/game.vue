<template>
  <div>
    <div v-if="game.id" >
      <el-page-header @back="goBack" title="Go back">
        <template slot="content">
          <span>Game #{{ game.id }}</span>
          <el-divider direction="vertical"></el-divider>
          <span>Rows: {{ game.height }}</span>
          <el-divider direction="vertical"></el-divider>
          <span>Columns: {{ game.width }}</span>
          <el-divider direction="vertical"></el-divider>
          <span>Bombs: {{ game.bombs }}</span>
        </template>
      </el-page-header>
      <el-divider />
      <div class="page-content">
        <el-row :gutter="20">
          <el-col :span="8">
            <el-button-group v-if="gamePlayable">
              <el-button type="warning" @click="abandonGame">Abandon</el-button>
              <el-button :disabled="gamePaused" type="primary" @click="pauseGame">Pause</el-button>
              <el-button :disabled="!gamePaused" type="primary" @click="continueGame">Continue</el-button>
            </el-button-group>
            <span v-if="!gamePlayable">No actions available</span>
          </el-col>
          <el-col :span="8">
            <h3>{{ gameMessage }}</h3>
          </el-col>
          <el-col :span="8">
            <span>Plays: {{ plays }}</span>
            <el-divider direction="vertical" />
            <span>Timer: {{ timer }}</span>
          </el-col>
        </el-row>
        <hr>
        <div v-loading="loading" id="game-board">
          <h1 v-if="gamePaused">Game paused</h1>
          <div v-if="!gamePaused" class="game-grid" :style="getGridStyle()">
            <cell
              v-for="(cell, i) in cells"
              :key="i"
              :cell="cell"
              @click.native="clearCell(cell)"
              @click.right.native="cycleCellFlag(cell)"
              @contextmenu.native.prevent
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import Cell from "./cell";

export default {
  name: "Game",
  components: { Cell },
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
      timer: 0,
      timerId: null,
      timerStarted: false,
      plays: 0,
      game: {
        id: null,
        state: null,
        width: null,
        height: null,
        bombs: null,
        last_started_at: null,
        total_time: null,
        available_plays: null
      },
      cells: []
    }
  },
  computed: {
    title() {
      return `Game #${this.game.id}`
    },
    gamePaused() {
      return this.game.state == "paused";
    },
    gameStarted() {
      return this.game.state == "started";
    },
    gameMessage() {
      if (this.game.state == "pending") return "Start the game by clicking in any cell";
      return `Game ${this.game.state}`;
    },
    gamePlayable() {
      return this.gamePaused || this.gameStarted;
    },
    gameUrl() {
      return `/api/users/${this.userId}/games/${this.gameId}`;
    }
  },
  created() {
    this.getGame();
  },
  methods: {
    getGame() {
      this.loading = true;
      let previousState = this.game.state;
      this.$http.get(this.gameUrl)
        .then(response => {
          this.game = response.body.game;
          this.plays = response.body.plays;
          this.cells = response.body.cells;
          if (previousState != this.game.state) this.updateTimer();
          if (this.gameStarted) this.startClock();
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
      if (this.game.state == "started") this.sendGameAction("pause");
      this.$emit('clearGame');
    },
    getGridStyle() {
      return `grid-template-columns: repeat(${this.game.width}, 40px);`;
    },
    clearCell(cell) {
      if (cell.mark != "no_mark") return;
      this.sendCellAction(cell, "clear");
    },
    cycleCellFlag(cell) {
      this.sendCellAction(cell, "cycle_mark");
    },
    pauseGame() {
      this.sendGameAction("pause");
      this.stopClock();
    },
    continueGame() {
      this.sendGameAction("continue");
    },
    abandonGame() {
      this.$confirm('Do you really want to abandon current game?', 'Warning', {
        confirmButtonText: 'OK',
        cancelButtonText: 'Cancel',
        type: 'warning'
      }).then(() => {
        this.sendGameAction('abandon');
        this.stopClock();
      }).catch(() => {});
    },
    sendGameAction(action) {
      this.loading = true;
      const url = `${this.gameUrl}/execute`;
      this.$http.post(url, { game: { game_action: action } })
        .then(response => {
          this.game.state = response.body.game.state;
          this.processResult(response.body.result);
        })
        .catch(error => {
          console.log("sendGameAction error", error);
          this.$alert(error.body.error, 'Error',  { confirmButtonText: 'OK' });
        })
        .finally(() => {
          this.loading = false;
        });
    },
    processResult(result) {
      if (!result) return;
      this.getGame();
      if (result == "won") {
        this.stopClock();
        this.$alert('Congratulations, you won!');
      }
      if (result == "explode") {
        this.stopClock();
        this.$alert('You lost...');
      }
    },
    sendCellAction(cell, action) {
      if (cell.cleared) return;
      if (this.game.state != "started" && this.game.state != "pending") return;

      this.loading = true;
      const url = `${this.gameUrl}/cells/${cell.id}/execute`;
      this.$http.post(url, { game: { cell_action: action } })
        .then(response => {
          cell.cleared = response.body.cell.cleared;
          cell.mark = response.body.cell.mark;
          this.game.state = response.body.game.state;
          this.plays = response.body.plays;
          this.processResult(response.body.result);
        })
        .catch(error => {
          console.log("sendCellAction error", error);
          this.$alert(error.body.error, 'Error',  { confirmButtonText: 'OK' });
        })
        .finally(() => {
          this.loading = false;
        });
    },
    stopClock() {
      clearInterval(this.timerId);
      this.timerStarted = false;
    },
    startClock() {
      if (this.timerStarted) return;
      this.timerId = setInterval(() => { this.timer++;  }, 1000);
      this.timerStarted = true;
    },
    updateTimer() {
      this.timer = this.game.total_time;
    }
  }
}
</script>

<style lang="scss">
  .game {
    &-grid {
      user-select: none;
      position: relative;
      overflow: auto;
      justify-content: center;
      align-content: center;
      display: grid;
      grid-template-columns: repeat(9, 1fr);
      grid-auto-rows: 1fr;
      &:before {
        content: '';
        width: 0;
        padding-bottom: 100%;
        grid-row: 1 / 1;
        grid-column: 1 / 1;
      }
      > *:first-child {
        grid-row: 1 / 1;
        grid-column: 1 / 1;
      }
    }
  }
</style>
