<template>
  <el-container>
    <el-header>MINESWEEPER</el-header>
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
        <div v-if="user.id">
          <el-page-header @back="clearUser" :content="title" />
          game list
        </div>
      </div>
    </el-main>
  </el-container>
</template>

<script>
export default {
  data: function () {
    return {
      loading: false,
      user: {
        id: null,
        name: null
      }
    }
  },
  computed: {
    title() {
      return `${this.user.name}'s games`
    }
  },
  methods: {
    clearUser() {
      this.user.id = null;
      this.user.name = null;
    },
    findUser() {
      console.log('send username', this.user.name);
      if (this.user.name) {
        this.loading = true;
        this.$http.post("/users", { user: {name: this.user.name} })
          .then(response => {
            console.log("user response", response.body);
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
