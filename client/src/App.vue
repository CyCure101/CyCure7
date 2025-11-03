<template>
  <div id="app">
    <!-- only render nav after auth is checked -->
    <nav class="navbar" v-if="checkedAuth">
      <div class="nav-brand">
        <img src="./assets/logo.png" alt="CyCure Logo" class="logo"/>
        <h1>CyCure</h1>
      </div>
      <div class="nav-links">
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

          <!-- NY TEMA-VÄXLINGSKNAPP -->
          <button @click="toggleTheme" class="theme-toggle-btn" :title="isDarkMode ? 'Växla till Light Mode' : 'Växla till Dark Mode'">
            <!-- Ikoner för Dark/Light Mode -->
            <span v-if="isDarkMode" class="text-xl">☀️</span>
            <span v-else class="text-xl">🌙</span>
          </button>

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
import {ref, onMounted, watch} from 'vue'
import {useRouter} from 'vue-router'
import apiService from './services/apiService'
import {isLoggedIn, currentUser} from '../auth'

export default {
  name: 'App',
  setup() {
    const router = useRouter()
    const checkedAuth = ref(false)

    // Läs initialt tema från Local Storage, annars Light Mode (false) som standard.
    const isDarkMode = ref(localStorage.getItem('theme') === 'dark')

    // Funktion för att applicera/ta bort 'dark-mode' klassen på BODY
    const applyTheme = (isDark) => {
      if (isDark) {
        document.body.classList.add('dark-mode')
        localStorage.setItem('theme', 'dark')
      } else {
        document.body.classList.remove('dark-mode')
        localStorage.setItem('theme', 'light')
      }
    }

    // Växla tema och uppdatera state
    const toggleTheme = () => {
      isDarkMode.value = !isDarkMode.value
    }

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

    // Titta på isDarkMode state och applicera temat när det ändras
    watch(isDarkMode, (newVal) => {
      applyTheme(newVal)
    })

    onMounted(() => {
      // Applicera temat omedelbart vid sidladdning baserat på Local Storage
      applyTheme(isDarkMode.value)
      checkAuth()
    })

    return {isLoggedIn, currentUser, logout, checkedAuth, isDarkMode, toggleTheme}
  }
}
</script>

<style>
/* ========================================================================= */
/* --- 0. GLOBAL CSS VARIABLES (THEMING) --- */
/* ========================================================================= */

:root {
  /* LIGHT MODE (DEFAULT - Nav och Body) */
  --color-text-body: #2c3e50;
  --color-bg-body: linear-gradient(135deg, #ffffff 0%, #f0f4f8 50%, #d9e2ec 100%);
  --color-bg-navbar: #2c3e50;
  --color-text-navbar: white;
  --color-border-navbar: none;
  --color-text-h1: white;
  --logo-height: 50px;
  --logo-filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.2));
  --color-bg-navlink: rgba(255, 255, 255, 0.1);
  --color-bg-navlink-hover: #34495e;
  --color-text-navlink-hover: white;
  --color-border-user-menu: rgba(255, 255, 255, 0.3);
  --color-bg-user-info: rgba(255, 255, 255, 0.15);
  --color-text-user-info: white;
  --color-loading: #2c3e50;
  --color-spinner-top: #2c3e50;
  --color-navlink-active-bg: #34495e;
  --color-navlink-active-text: white;
  --color-navlink-active-border: none;

  /* PROGRESS & CARDS (Light Mode) */
  --color-bg-card: white;
  --color-border-card: 1px solid #ecf0f1;
  --color-text-h1-home: #2c3e50;
  --color-text-p-home: #7f8c8d;
  --color-text-h2-progress: #2c3e50;
  --color-bg-stat-card: linear-gradient(135deg, #f6f9fc 0%, #e9eff5 100%);
  --color-border-stat-hover: #3498db;
  --color-text-stat-value: #2c3e50;
  --color-text-stat-label: #7f8c8d;

  /* PROGRESS BAR SPECIFICS (Light Mode FIX) */
  --color-bg-progress-container: #e9ecef;
  --color-gradient-progress-bar: linear-gradient(90deg, #3498db, #2ecc71); /* FIX 1 */
  --color-shadow-progress-bar: rgba(0, 0, 0, 0.1); /* FIX 2 */
  --color-border-progress-bar: #ced4da; /* FIX 3 */
  --color-text-overlay: #2c3e50;

  --color-text-card-h3: #2c3e50;
  --color-text-card-p: #7f8c8d;
  --color-bg-quiz-type: #3498db;
  --color-text-question-count: #7f8c8d;
  --color-bg-btn-primary: #3498db;
  --color-bg-btn-primary-hover: #2980b9;
  --color-bg-btn-secondary: #266c01;
  --color-bg-btn-secondary-hover: #2c791a;
  --color-bg-progress-badge: linear-gradient(135deg, #2ecc71, #27ae60);
  --color-text-modal-h2: #e74c3c;
  --color-text-modal-p: #2c3e50;
  --color-bg-modal-overlay: rgba(0, 0, 0, 0.7);

  /* TABLE SPECIFICS (Light Mode FIX) */
  --color-bg-table: #f9f9f9; /* FIX 4 */
  --color-shadow-table: rgba(0, 0, 0, 0.05); /* FIX 5 */
  --color-border-table-row: #e9ecef; /* FIX 6 */
  --color-gradient-table-header: linear-gradient(135deg, #3498db, #2ecc71); /* FIX 7 */
  --color-bg-table-header: #3498db; /* Fallback */
  --color-text-table-header: white; /* FIX 8 */
  --color-bg-table-cell: #ffffff; /* FIX 9 */
  --color-bg-table-hover: #f1f1f1; /* FIX 10 */
}

.dark-mode {
  /* DARK MODE (OVERRIDE - Nav och Body) */
  --color-text-body: #E6EDF3;
  --color-bg-body: #0D1117;
  --color-bg-navbar: rgba(22, 27, 34, 0.9);
  --color-text-navbar: #E6EDF3;
  --color-border-navbar: 1px solid #21262D;
  --color-text-h1: #00A3FF;
  --logo-height: 70px;
  --logo-filter: drop-shadow(0 0 10px rgba(0, 255, 179, 0.3));
  --color-bg-navlink: rgba(33, 38, 45, 0.6);
  --color-bg-navlink-hover: linear-gradient(135deg, #00A3FF, #00FFB3);
  --color-text-navlink-hover: #0D1117;
  --color-border-user-menu: rgba(0, 255, 179, 0.2);
  --color-bg-user-info: rgba(0, 163, 255, 0.15);
  --color-text-user-info: #00FFB3;
  --color-loading: #00A3FF;
  --color-spinner-top: #00A3FF;
  --color-navlink-active-bg: linear-gradient(135deg, #00A3FF, #00FFB3);
  --color-navlink-active-text: #0D1117;
  --color-navlink-active-border: 1px solid #00FFB3;

  /* PROGRESS & CARDS (Dark Mode) */
  --color-bg-card: #161B22;
  --color-border-card: 1px solid #21262D;
  --color-text-h1-home: #00A3FF;
  --color-text-p-home: #8B949E;
  --color-text-h2-progress: #00FFB3;
  --color-bg-stat-card: #0D1117;
  --color-border-stat-hover: #00A3FF;
  --color-text-stat-value: #00FFB3;
  --color-text-stat-label: #8B949E;

  /* PROGRESS BAR SPECIFICS (Dark Mode) */
  --color-bg-progress-container: #21262D;
  --color-gradient-progress-bar: linear-gradient(90deg, #00A3FF, #00FFB3);
  --color-shadow-progress-bar: rgba(0, 163, 255, 0.15);
  --color-border-progress-bar: #21262D;
  --color-text-overlay: #E6EDF3;

  --color-text-card-h3: #E6EDF3;
  --color-text-card-p: #8B949E;
  --color-bg-quiz-type: #00A3FF;
  --color-text-question-count: #8B949E;
  --color-bg-btn-primary: linear-gradient(135deg, #00A3FF, #00FFB3);
  --color-bg-btn-primary-hover: linear-gradient(135deg, #00FFB3, #00A3FF);
  --color-bg-btn-secondary: #2ecc71;
  --color-bg-btn-secondary-hover: #27ae60;
  --color-bg-progress-badge: linear-gradient(135deg, #00FFB3, #00A3FF);
  --color-text-modal-h2: #FF4C4C;
  --color-text-modal-p: #E6EDF3;
  --color-bg-modal-overlay: rgba(0, 0, 0, 0.9);

  /* TABLE SPECIFICS (Dark Mode) */
  --color-bg-table: rgba(13, 17, 23, 0.8);
  --color-shadow-table: rgba(0, 0, 0, 0.4);
  --color-border-table-row: #21262D;
  --color-gradient-table-header: linear-gradient(135deg, #00A3FF, #00FFB3);
  --color-bg-table-header: #00A3FF; /* Fallback */
  --color-text-table-header: #0D1117;
  --color-bg-table-cell: rgba(22, 27, 34, 0.7);
  --color-bg-table-hover: rgba(0, 255, 179, 0.08);
}

/* ========================================================================= */
/* --- 1. CORE LAYOUT & TYPOGRAPHY (Uses Variables) --- */
/* ========================================================================= */

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  background: var(--color-bg-body);
  color: var(--color-text-body);
  min-height: 100vh;
  background-attachment: fixed;
  transition: background 0.5s ease, color 0.5s ease;
}

#app {
  min-height: 100vh;
}

/* ========================================================================= */
/* --- 2. NAVBAR (Uses Variables) --- */
/* ========================================================================= */

.navbar {
  background: var(--color-bg-navbar);
  color: var(--color-text-navbar);
  padding: 1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: var(--color-border-navbar);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
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
  height: var(--logo-height);
  width: auto;
  filter: var(--logo-filter);
  transition: transform 0.3s ease, filter 0.3s ease, height 0.3s ease;
}

.logo:hover {
  transform: scale(1.08);
  filter: drop-shadow(0 0 15px rgba(0, 255, 179, 0.5)); /* Dark-inspired hover */
}

.nav-brand h1 {
  font-size: 1.8rem;
  font-weight: 700;
  letter-spacing: 1px;
  color: var(--color-text-h1);
  /* Dark Mode text shadow används för båda */
  text-shadow: 0 0 10px rgba(0, 163, 255, 0.4);
}

/* ========================================================================= */
/* --- 3. NAV LINKS & THEME BUTTON (Uses Variables) --- */
/* ========================================================================= */

.nav-links {
  display: flex;
  gap: 0.75rem;
  align-items: center;
}

.nav-link {
  color: var(--color-text-navbar); /* Använd navbar textfärg */
  text-decoration: none;
  padding: 0.6rem 1.2rem;
  border-radius: 8px;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 500;
  background: var(--color-bg-navlink);
  border: 1px solid transparent;
}

.nav-link:hover {
  background: var(--color-bg-navlink-hover);
  color: var(--color-text-navlink-hover);
  transform: translateY(-2px);
  box-shadow: 0 0 15px rgba(0, 255, 179, 0.3);
}

.nav-link.router-link-active {
  background: var(--color-navlink-active-bg);
  color: var(--color-navlink-active-text);
  font-weight: 600;
  border: var(--color-navlink-active-border);
  box-shadow: 0 0 10px rgba(0, 255, 179, 0.4);
}

/* Theme Toggle Button Style */
.theme-toggle-btn {
  background: var(--color-bg-navlink);
  color: var(--color-text-navbar);
  border: 1px solid var(--color-border-user-menu);
  padding: 0.6rem 0.8rem;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 500;
  transition: all 0.3s ease;
  line-height: 1; /* Fixa ikonens vertikala position */
}

.theme-toggle-btn:hover {
  background: var(--color-bg-navlink-hover);
  color: var(--color-text-navlink-hover);
  transform: translateY(-2px);
  box-shadow: 0 0 10px rgba(0, 163, 255, 0.3);
}

/* ========================================================================= */
/* --- 4. USER MENU & LOGOUT (Uses Variables) --- */
/* ========================================================================= */

.user-menu {
  display: flex;
  gap: 0.5rem;
  align-items: center;
  margin-left: 1rem;
  padding-left: 1rem;
  border-left: 2px solid var(--color-border-user-menu);
}

.user-info {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.6rem 1rem;
  background: var(--color-bg-user-info);
  border-radius: 8px;
  font-weight: 500;
  color: var(--color-text-user-info);
  border: 1px solid var(--color-border-user-menu);
}

/* Logout button behåller Dark Mode stilen (Rött/Cyan) */
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
/* --- 5. MAIN CONTENT & LOADING --- */
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
  color: var(--color-loading);
}

.spinner {
  border: 4px solid rgba(0, 255, 179, 0.1);
  border-top: 4px solid var(--color-spinner-top);
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
/* --- 6. RESPONSIVE --- */
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
    width: 100%;
  }

  /* Liten justering för att få med temaknappen på mobil */
  .nav-links > * {
    flex-grow: 1;
  }

  .nav-brand h1 {
    font-size: 1.4rem;
  }

  .logo {
    height: 40px;
  }

  .dark-mode .logo {
    height: 50px; /* Mindre på mobil även i dark mode */
  }

  .user-menu {
    margin-left: 0;
    padding-left: 0;
    border-left: none;
    border-top: 2px solid var(--color-border-user-menu);
    padding-top: 0.5rem;
    width: 100%;
    justify-content: center;
  }
}
</style>
