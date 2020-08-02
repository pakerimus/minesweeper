<template>
  <div v-loading="loading">
    <div v-if="!gameId" >
      <el-page-header @back="clearUser" :content="title" />
      <div class="page-content">
        <div class="list">
          <el-table
            :data="games"
            style="width: 100%">
            <el-table-column
              prop="id"
              label="#" />
            </el-table-column>
            <el-table-column
              prop="state"
              label="State" />
            </el-table-column>
            <el-table-column
              prop="width"
              label="Width" />
            <el-table-column
              prop="height"
              label="Height" />
            <el-table-column
              prop="bombs"
              label="Bombs" />
            </el-table-column>
            <el-table-column
              prop="last_started_at"
              label="Last started at" />
            </el-table-column>
            <el-table-column
              prop="total_time"
              label="Total time" />
            </el-table-column>
            <el-table-column>
              <template slot-scope="scope">
                <el-button @click="setGame(scope.row.id)" type="primary">Open</el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </div>
    </div>
    <game v-if="gameId" :user-id="user.id" :game-id="gameId" @clearGame="() => clearGame()"/>
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
    return {
      loading: false,
      games: [],
      gameId: null
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
          console.log("games response", response.body);
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
    }
  }
}
</script>
