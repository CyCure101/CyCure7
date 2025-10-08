<template>
  <div id="app">
    <nav class="navbar">
      <div class="nav-brand">
        <h1>CyCure</h1>
      </div>
      <div class="nav-links">
        <router-link to="/" class="nav-link">Home</router-link>
        <router-link to="/login" class="nav-link" v-if="!isLoggedIn">Login</router-link>
        <router-link to="/register" class="nav-link" v-if="!isLoggedIn">Register</router-link>
        <span class="nav-link" v-if="isLoggedIn">Welcome, {{ user.username }}!</span>
        <button @click="logout" class="nav-link logout-btn" v-if="isLoggedIn">Logout</button>
      </div>
    </nav>
    
    <main class="main-content">
      <router-view />
    </main>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import apiService from './services/apiService'

export default {
  name: 'App',
  setup() {
    const router = useRouter()
    const isLoggedIn = ref(false)
    const user = ref({})

    const checkAuth = async () => {
      try {
        const response = await apiService.getCurrentUser()
        if (response.success) {
          isLoggedIn.value = true
          user.value = response.user
        }
      } catch (error) {
        isLoggedIn.value = false
        user.value = {}
      }
    }

    const logout = async () => {
      try {
        await apiService.logout()
        isLoggedIn.value = false
        user.value = {}
        router.push('/')
      } catch (error) {
        console.error('Logout error:', error)
      }
    }

    onMounted(() => {
      checkAuth()
    })

    return {
      isLoggedIn,
      user,
      logout
    }
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
