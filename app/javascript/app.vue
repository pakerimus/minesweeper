<template>
  <el-container>
    <el-header>
      <h1>MINESWEEPER</h1>
    </el-header>
    <el-main>
      <div id="app" v-loading="loading">
        <div v-if="!user.id">
          <h1>Welcome!</h1>
          <el-form inline :model="user" class="demo-form-inline">
            <el-form-item label="Who are you?">
              <el-input v-model="user.name" placeholder="Username"></el-input>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="findUser">Send</el-button>
            </el-form-item>
          </el-form>
        </div>
        <game-list v-if="user.id" :user="user" @clearUser="() => clearUser()"/>
      </div>
    </el-main>
  </el-container>
</template>

<script>
import GameList from "./gameList";

export default {
  components: { GameList },
  data: function () {
    return {
      loading: false,
      user: {
        id: null,
        name: null
      }
    }
  },
  methods: {
    clearUser() {
      this.user.id = null;
      this.user.name = null;
    },
    findUser() {
      if (this.user.name) {
        this.loading = true;
        this.$http.post("/api/users", { user: {name: this.user.name} })
          .then(response => {
            this.user.id = response.body.user.id;
            this.user.name = response.body.user.name;
          })
          .catch(error => {
            console.log("user error", error);
            this.$alert(error.body.error, 'Error',  { confirmButtonText: 'OK' });
          })
          .finally(() => {
            this.loading = false;
          });
      } else {
        this.$alert("Username is required", 'Error',  { confirmButtonText: 'OK' });
      }
    }
  }
}
</script>
