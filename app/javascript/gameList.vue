<template>
  <div v-loading="loading">
    <div v-if="!gameId" >
      <el-page-header @back="clearUser" title="Logout" :content="title" />

      <div class="page-header">
        <div class="controls">
          <el-button slot="append" type="primary" @click="newGameDialogVisible = true">
            <i class="el-icon-plus"></i> New Game
          </el-button>
        </div>
      </div>
      <div class="page-content">
        <div class="list">
          <el-table
            :data="games"
            style="width: 100%">
            <el-table-column prop="id" label="#" />
            <el-table-column prop="state" label="State" />
            <el-table-column prop="width" label="Width" />
            <el-table-column prop="height" label="Height" />
            <el-table-column prop="bombs" label="Bombs" />
            <el-table-column prop="last_started_at" label="Last started at" />
            <el-table-column prop="total_time" label="Total time" />
            <el-table-column>
              <template slot-scope="scope">
                <el-button @click="setGame(scope.row.id)" type="primary">Open</el-button>
                <el-button @click="confirmDeleteGame(scope.row.id)" type="danger">Delete</el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </div>
    </div>

    <game v-if="gameId" :user-id="user.id" :game-id="gameId" @clearGame="() => clearGame()" />

    <el-dialog title="New Game" :visible.sync="newGameDialogVisible">
      <el-form :model="newGame" :rules="newGameRules" ref="newGameForm">
        <el-form-item prop="width" label="Columns" :label-width="formLabelWidth">
          <el-input v-model="newGame.width" />
        </el-form-item>
        <el-form-item prop="height" label="Rows" :label-width="formLabelWidth">
          <el-input v-model="newGame.height" />
        </el-form-item>
        <el-form-item prop="bombs" label="Bombs" :label-width="formLabelWidth">
          <el-input v-model="newGame.bombs" />
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="newGameDialogVisible = false">Cancel</el-button>
        <el-button type="primary" @click="validateNewGameForm">Confirm</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import Game from "./game";

export default {
  name: "GameList",
  components: { Game },
  props: {
    user: {
      type: Object,
      required: true
    }
  },
  data: function () {
    let tenOrMoreValidator = (rule, value, callback) => {
      if (value === '') {
        callback(new Error("Can't be blank"));
      } else {
        let reg = new RegExp(/^[0-9]{2}$/);
        if (!reg.test(value)) {
          callback(new Error("Must have 2 digits"));
        } else {
          callback();
        }
      }
    };

    return {
      loading: false,
      games: [],
      gameId: null,
      newGameDialogVisible: false,
      newGame: {
        width: 10,
        height: 10,
        bombs: 10
      },
      formLabelWidth: '120px',
      newGameRules: {
        width:  [ { required: true, validator: tenOrMoreValidator, trigger: "blur" } ],
        height: [ { required: true, validator: tenOrMoreValidator, trigger: "blur" } ],
        bombs:  [ { required: true, validator: tenOrMoreValidator, trigger: "blur" } ]
      },
    }
  },
  computed: {
    title() {
      return `${this.user.name}'s games`
    }
  },
  created() {
    this.getGameList();
  },
  methods: {
    clearUser() {
      this.$emit('clearUser');
    },
    getGameList() {
      this.loading = true;
      this.$http.get(`/api/users/${this.user.id}/games`)
        .then(response => {
          this.games = response.body.games;
        })
        .catch(error => {
          console.log("games error", error);
          this.$alert(error.body.error, 'Error',  { confirmButtonText: 'OK' });
        })
        .finally(() => {
          this.loading = false;
        });
    },
    setGame(gameId) {
      this.games = [];
      this.gameId = gameId;
    },
    clearGame() {
      this.gameId = null;
      this.getGameList();
    },
    validateNewGameForm() {
      this.$refs.newGameForm.validate((valid) => {
        if (valid) {
          this.createGame();
        } else {
          return false;
        }
      });
    },
    createGame() {
      this.loading = true;
      this.$http.post(`/api/users/${this.user.id}/games`, { game: this.newGame })
        .then((response) => {
          this.newGameDialogVisible = false;
          this.setGame(response.body.game.id);
        })
        .catch(error => {
          console.log("user error", error);
          this.$alert(error.body.error, 'Error',  { confirmButtonText: 'OK' });
        })
        .finally(() => {
          this.loading = false;
        });
    },
    confirmDeleteGame(gameId) {
      this.$confirm('This will permanently delete the game. Continue?', 'Warning', {
        confirmButtonText: 'OK',
        cancelButtonText: 'Cancel',
        type: 'warning'
      }).then(() => {
        this.deleteGame(gameId);
      }).catch(() => {
        this.$message({
          type: 'info',
          message: 'Delete canceled'
        });
      });
    },
    deleteGame(gameId) {
      this.loading = true;
      this.$http.delete(`/api/users/${this.user.id}/games/${gameId}`)
        .then(() => {
          this.$message({
            type: 'success',
            message: 'Game deleted'
          });
          this.getGameList();
        })
        .catch(error => {
          console.log("user error", error);
          this.$alert(error.body.error, 'Error',  { confirmButtonText: 'OK' });
        })
        .finally(() => {
          this.loading = false;
        });
    }
  }
}
</script>
