<template>
  <div id="app">
    <!-- only render nav after auth is checked -->
    <nav class="navbar" v-if="checkedAuth">
      <div class="nav-brand">
        <img src="./assets/logo.png" alt="CyCure Logo" class="logo"/>
        <h1>CyCure</h1>
      </div>
      <div class="nav-links" v-if="isLoggedIn">
        <router-link to="/" class="nav-link">Home
        </router-link>

        <template v-if="!isLoggedIn">
          <router-link to="/login" class="nav-link">
            <span class="icon"></span>Login
          </router-link>
          <router-link to="/register" class="nav-link">Register
          </router-link>
        </template>

        <template v-else>
          <router-link to="/myresults" class="nav-link">My Results
          </router-link>
          <div class="user-menu">
            <span class="user-info">
              <span class="icon">👤</span> {{ currentUser.username }}
            </span>
            <button @click="logout" class="logout-btn">Logout
            </button>
          </div>
        </template>
      </div>
    </nav>

    <main class="main-content" v-if="checkedAuth">
      <router-view/>
    </main>

    <div v-else class="loading">
      <div class="spinner"></div>
      Loading...
    </div>
  </div>
</template>

<script>
import {ref, onMounted} from 'vue'
import {useRouter} from 'vue-router'
import apiService from './services/apiService'
import {isLoggedIn, currentUser} from '../auth'

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

    return {isLoggedIn, currentUser, logout, checkedAuth}
  }
}
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

/* Global layout */
body {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  background: #0D1117; /* Night Code */
  color: #E6EDF3; /* Soft White */
  min-height: 100vh;
  background-attachment: fixed;
}

#app {
  min-height: 100vh;
}

/* ========================================================================= */
/* --- NAVBAR --- */
/* ========================================================================= */

.navbar {
  background: rgba(22, 27, 34, 0.9); /* Dark Panel */
  color: #E6EDF3;
  padding: 1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #21262D;
  box-shadow: 0 4px 20px rgba(0, 163, 255, 0.15);
  position: sticky;
  top: 0;
  z-index: 100;
  backdrop-filter: blur(10px);
}

/* Brand / Logo */
.nav-brand {
  display: flex;
  align-items: center;
  gap: 1rem;

}

.logo {
  display: block;
  height: 70px;
  width: auto;
  filter: drop-shadow(0 0 10px rgba(0, 255, 179, 0.3));
  transition: transform 0.3s ease, filter 0.3s ease;

}

.logo:hover {
  transform: scale(1.08);
  filter: drop-shadow(0 0 15px rgba(0, 255, 179, 0.5));
}

.nav-brand h1 {
  font-size: 1.8rem;
  font-weight: 700;
  letter-spacing: 1px;
  color: #00A3FF; /* Cyber Blue */
  text-shadow: 0 0 10px rgba(0, 163, 255, 0.4);
}

/* ========================================================================= */
/* --- NAV LINKS --- */
/* ========================================================================= */

.nav-links {
  display: flex;
  gap: 0.75rem;
  align-items: center;
}

.nav-link {
  color: #E6EDF3;
  text-decoration: none;
  padding: 0.6rem 1.2rem;
  border-radius: 8px;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 500;
  background: rgba(33, 38, 45, 0.6);
  border: 1px solid transparent;
}

.nav-link:hover {
  background: linear-gradient(135deg, #00A3FF, #00FFB3);
  color: #0D1117;
  transform: translateY(-2px);
  box-shadow: 0 0 15px rgba(0, 255, 179, 0.3);
}

.nav-link.router-link-active {
  background: linear-gradient(135deg, #00A3FF, #00FFB3);
  color: #0D1117;
  font-weight: 600;
  border: 1px solid #00FFB3;
  box-shadow: 0 0 10px rgba(0, 255, 179, 0.4);
}

/* ========================================================================= */
/* --- USER MENU --- */
/* ========================================================================= */

.user-menu {
  display: flex;
  gap: 0.5rem;
  align-items: center;
  margin-left: 1rem;
  padding-left: 1rem;
  border-left: 2px solid rgba(0, 255, 179, 0.2);
}

.user-info {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.6rem 1rem;
  background: rgba(0, 163, 255, 0.15);
  border-radius: 8px;
  font-weight: 500;
  color: #00FFB3;
  border: 1px solid rgba(0, 255, 179, 0.3);
}

/* ========================================================================= */
/* --- LOGOUT BUTTON --- */
/* ========================================================================= */

.logout-btn {
  background: linear-gradient(135deg, #FF4C4C, #C62828);
  color: white;
  border: none;
  padding: 0.6rem 1.2rem;
  border-radius: 8px;
  cursor: pointer;
  font-size: inherit;
  font-weight: 600;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  box-shadow: 0 0 8px rgba(255, 76, 76, 0.3);
}

.logout-btn:hover {
  background: linear-gradient(135deg, #FF6B6B, #E53935);
  transform: translateY(-2px);
  box-shadow: 0 0 15px rgba(255, 76, 76, 0.5);
}

/* ========================================================================= */
/* --- MAIN CONTENT & LOADING --- */
/* ========================================================================= */

.main-content {
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

/* Loading Spinner */
.loading {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  gap: 1rem;
  font-size: 1.2rem;
  color: #00A3FF;
}

.spinner {
  border: 4px solid rgba(0, 255, 179, 0.1);
  border-top: 4px solid #00A3FF;
  border-radius: 50%;
  width: 50px;
  height: 50px;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* ========================================================================= */
/* --- RESPONSIVE --- */
/* ========================================================================= */

@media (max-width: 768px) {
  .navbar {
    flex-direction: column;
    gap: 1rem;
    padding: 1rem;
  }

  .nav-links {
    flex-wrap: wrap;
    justify-content: center;
  }

  .nav-brand h1 {
    font-size: 1.4rem;
  }

  .logo {
    height: 40px;
  }

  .user-menu {
    margin-left: 0;
    padding-left: 0;
    border-left: none;
    border-top: 2px solid rgba(0, 255, 179, 0.2);
    padding-top: 0.5rem;
    width: 100%;
    justify-content: center;
  }
}
</style>

