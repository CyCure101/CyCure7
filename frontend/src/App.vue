<script setup>
import { computed } from 'vue';
import { useRoute } from 'vue-router';

const route = useRoute();

// Computed property to determine if the header should be visible.
// It will be false only when the current path is exactly '/login'.
const showHeader = computed(() => route.path !== '/login');
</script>

<template>
  <div id="app">
    <!-- 1. The Header component, now conditionally rendered -->
    <header class="app-header" v-if="showHeader">
      <!-- Left -->
      <div class="header-left">
        <img alt="CyCure Logo" class="logo" src="../public/Cyber-Security-Logo-PNG.png" />
        <a href="/main" class="no-link-style">
        <h1 >CyCure101</h1>
        </a>
      </div>

      <!-- Right -->
      <div class="header-right">
        <router-link to="/results">Mina resultat</router-link>
        <span>Välkommen tillbaka, User</span>
        <router-link to="/login">Logga ut</router-link>
      </div>
    </header>

    <main class="content-wrapper">
      <router-view />
    </main>
  </div>
</template>

<style scoped>
.app-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background-color: #ffffff;
  padding: 0.5rem 1rem;
  color: #000000;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.no-link-style {
  text-decoration: none;
  color: inherit;
  cursor: pointer;
}

/* left */
.header-left {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.logo {
  width: 32px;
  height: 32px;
}

/* center nav */
.header-center {
  display: flex;
  gap: 1rem;
  text-decoration: none;
  color: #000000;
  font-weight: bold;
}

.header-center a {
  text-decoration: none;
  color: #42b883;
  font-weight: bold;
}

.header-center a.router-link-exact-active {
  color: #42b883;
}

/* right */
.header-right {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.header-right a {
  text-decoration: none;
  color: #000000;
  font-weight: bold;
}

.user-circle {
  width: 32px;
  height: 32px;
  background-color: #00aaff;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
}
</style>
