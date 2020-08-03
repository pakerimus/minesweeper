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
          <el-col :span="8"><span>Actions</span></el-col>
          <el-col :span="8">{{ gameMessage }}</el-col>
          <el-col :span="8"><span>Timer</span></el-col>
        </el-row>
        <hr>
        <div v-loading="loading" id="game-board">
          <div class="game-grid" :style="getGridStyle()">
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
      gameMessage: null,
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
      timer: 0,
      cells: []
    }
  },
  computed: {
    title() {
      return `Game #${this.game.id}`
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
      this.$http.get(this.gameUrl)
        .then(response => {
          this.game = response.body.game;
          this.cells = response.body.cells;
          if (this.game.state == "pending") {
            this.gameMessage = "Start the game by clicking in any cell"
          } else {
            this.gameMessage = this.game.state;
          }
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
    refreshCells() {
      this.loading = true;
      this.$http.get(`/api/users/${this.userId}/games/${this.game.id}/cells`)
        .then(response => {
          this.cells = response.body.cells;
        })
        .catch(error => {
          console.log("cells error", error);
          this.$alert(error.body.error, 'Error',  { confirmButtonText: 'OK' });
        })
        .finally(() => {
          this.loading = false;
        });
    },
    getGridStyle() {
      return `grid-template-columns: repeat(${this.game.width}, 40px);`;
    },
    clearCell(cell) {
      this.sendCellAction(cell, "clear");
    },
    cycleCellFlag(cell) {
      this.sendCellAction(cell, "cycle_mark");
    },
    sendGameAction(action) {
      this.loading = true;
      const url = `${this.gameUrl}/execute`;
      this.$http.post(url, { game: { game_action: action } })
        .then(response => {
          this.game.state = response.body.game.state;
          result = response.body.result;
          if (result == "refresh_grid") this.refreshCells();
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
      // if (result == "start_game") this.refreshCells();
      // if (result == "refresh_grid") this.refreshCells();
      if (result == "won") {
        this.$alert('Congratulations, you won!');
      }
      if (result == "explode") {
        this.$alert('You lost...');
      }
    },
    sendCellAction(cell, action) {
      if (cell.cleared) return;

      this.loading = true;
      const url = `${this.gameUrl}/cells/${cell.id}/execute`;
      this.$http.post(url, { game: { cell_action: action } })
        .then(response => {
          cell.cleared = response.body.cell.cleared;
          cell.mark = response.body.cell.mark;
          this.game.state = response.body.game.state;
          this.processResult(response.body.result);
        })
        .catch(error => {
          console.log("sendCellAction error", error);
          this.$alert(error.body.error, 'Error',  { confirmButtonText: 'OK' });
        })
        .finally(() => {
          this.loading = false;
        });
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
