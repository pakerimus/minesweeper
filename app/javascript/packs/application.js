// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("@rails/activestorage").start()
require("channels")

import Vue from 'vue'
import VueResource from 'vue-resource'
import ElementUI          from 'element-ui';
import locale             from 'element-ui/lib/locale/lang/en'

import 'element-ui/lib/theme-chalk/display.css';
import 'element-ui/lib/theme-chalk/index.css';

import App from '../app.vue'

Vue.use(VueResource)
Vue.use(ElementUI, { locale })

document.addEventListener('DOMContentLoaded', () => {
  Vue.http.headers.common['X-CSRF-TOKEN'] = document.querySelector('meta[name="csrf-token"]').content;
  const app = new Vue({
    render: h => h(App),
    el: '#minesweeper_app'
  }).$mount()
})

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
