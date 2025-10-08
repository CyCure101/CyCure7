<template>
  <div id="app">
    <!-- only render nav after auth is checked -->
    <nav class="navbar" v-if="checkedAuth">
      <div class="nav-brand">
        <h1>CyCure</h1>
      </div>
      <div class="nav-links" v-if="isLoggedIn">
        <router-link to="/" class="nav-link">Home</router-link>

        <template v-if="!isLoggedIn">
          <router-link to="/login" class="nav-link">Login</router-link>
          <router-link to="/register" class="nav-link">Register</router-link>
        </template>

        <template v-else>
          <span class="nav-link">Welcome, {{ currentUser.username }}!</span>
          <button @click="logout" class="nav-link logout-btn">Logout</button>
        </template>
      </div>
    </nav>

    <main class="main-content" v-if="checkedAuth">
      <router-view />
    </main>

    <div v-else class="loading">
      Loading...
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import apiService from './services/apiService'
import { isLoggedIn, currentUser } from '../auth'

export default {
  name: 'App',
  setup() {
    const router = useRouter()
    const checkedAuth = ref(false)

    const checkAuth = async () => {
      try {
        const response = await apiService.getCurrentUser()
        if (response && response.user) {
          isLoggedIn.value = true
          currentUser.value = response.user
        } else {
          isLoggedIn.value = false
          currentUser.value = {}
        }
      } catch (error) {
        isLoggedIn.value = false
        currentUser.value = {}
      } finally {
        checkedAuth.value = true
      }
    }

    const logout = async () => {
      try {
        await apiService.logout()
        isLoggedIn.value = false
        currentUser.value = {}
        router.push('/login')
      } catch (error) {
        console.error('Logout error:', error)
      }
    }

    onMounted(() => {
      checkAuth()
    })

    return { isLoggedIn, currentUser, logout, checkedAuth }
  }
}
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: Arial, sans-serif;
  background-color: #f5f5f5;
}

#app {
  min-height: 100vh;
}

.navbar {
  background-color: #2c3e50;
  color: white;
  padding: 1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.nav-brand h1 {
  font-size: 1.5rem;
}

.nav-links {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.nav-link {
  color: white;
  text-decoration: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.nav-link:hover {
  background-color: #34495e;
}

.logout-btn {
  background: none;
  border: none;
  cursor: pointer;
  font-size: inherit;
}

.main-content {
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}
</style>
