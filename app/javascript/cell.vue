<template>
  <div class="game-cell" :class="cellColorClass">
    <div v-if="showIcon">
      <i :class="cellIconClass"></i>
    </div>
    <div v-if="!showIcon">
      {{ cellTitle }}
    </div>
  </div>
</template>

<script>
export default {
  name: "Cell",
  props: {
    cell: {
      type: Object,
      required: true
    }
  },
  data: function () {
    return {
      loading: false
    }
  },
  computed: {
    showIcon() {
      if (!this.cell.cleared && !this.cell.bomb) {
        return true;
      } else if (this.cell.cleared && this.cell.bomb) {
        return true;
      } else if (this.cell.mark !== "no_mark") {
        return true;
      } else {
        return false;
      }
    },
    cellColorClass() {
      if (this.cell.mark == "question") {
        return "game-mark-with-question";
      } else if (this.cell.mark == "with_bomb") {
        return "game-mark-with-bomb";
      } else if (this.cell.cleared && this.cell.bomb) {
        return "game-bomb";
      } else if (this.cell.cleared && !this.cell.bomb) {
        return "game-cleared";
      } else {
        return "";
      }
    },
    cellIconClass() {
      if (this.cell.cleared && this.cell.bomb) {
        return "el-icon-error";
      } else if (this.cell.mark == "question") {
        return "el-icon-question";
      } else if (this.cell.mark == "with_bomb") {
        return "el-icon-s-flag";
      } else {
        return "";
      }
    },
    cellTitle() {
      if (this.cell.adjacent_bombs == 0) return "";
      return this.cell.adjacent_bombs;
    }
  }
}
</script>

<style lang="scss">
  .game {
    &-cell {
      align-items: center;
      background: rgba(0, 0, 0, 0.1);
      border: 1px white solid;
      color: #2c3e50;
      cursor: pointer;
      display: flex;
      font-size: 1.3em;
      justify-content: center;
      min-height: 35px;
      min-width: 35px;
    }
    &-bomb {
      background: #c0392b;
    }
    &-cleared {
      background: rgba(0, 0, 0, 0.05);
    }
    &-mark-with-question {
      background: #E6A23C;
    }
    &-mark-with-bomb {
      background: #67C23A;
    }
  }
</style>
