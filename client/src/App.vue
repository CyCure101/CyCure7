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

body {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  background: linear-gradient(135deg, #ffffff 0%, #f0f4f8 50%, #d9e2ec 100%);
  min-height: 100vh;
  background-attachment: fixed;
}

#app {
  min-height: 100vh;
}

/* Navbar Styles */
.navbar {
  background-color: #2c3e50;
  color: white;
  padding: 1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  position: sticky;
  top: 0;
  z-index: 100;
}

.nav-brand {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.logo {
  height: 50px;
  width: auto;
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.2));
  transition: transform 0.3s ease;
}

.logo:hover {
  transform: scale(1.05);
}

.nav-brand h1 {
  font-size: 1.8rem;
  font-weight: 700;
  letter-spacing: 1px;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
}

.nav-links {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

.nav-link {
  color: white;
  text-decoration: none;
  padding: 0.6rem 1.2rem;
  border-radius: 8px;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 500;
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
}

.nav-link:hover {
  background: #34495e;
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
}

.nav-link.router-link-active {
  background: #34495e;
  font-weight: 600;
}

.icon {
  font-size: 1.1rem;
}

.user-menu {
  display: flex;
  gap: 0.5rem;
  align-items: center;
  margin-left: 1rem;
  padding-left: 1rem;
  border-left: 2px solid rgba(255, 255, 255, 0.3);
}

.user-info {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.6rem 1rem;
  background: rgba(255, 255, 255, 0.15);
  border-radius: 8px;
  font-weight: 500;
}

.logout-btn {
  background: rgba(255, 59, 48, 0.8);
  color: white;
  border: none;
  padding: 0.6rem 1.2rem;
  border-radius: 8px;
  cursor: pointer;
  font-size: inherit;
  font-weight: 500;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.logout-btn:hover {
  background: rgba(255, 59, 48, 1);
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(255, 59, 48, 0.4);
}

/* Main Content */
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
  color: #2c3e50;
}

.spinner {
  border: 4px solid rgba(44, 62, 80, 0.1);
  border-top: 4px solid #2c3e50;
  border-radius: 50%;
  width: 50px;
  height: 50px;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

/* Responsive Design */
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
    border-top: 2px solid rgba(255, 255, 255, 0.3);
    padding-top: 0.5rem;
    width: 100%;
    justify-content: center;
  }
}
</style>
