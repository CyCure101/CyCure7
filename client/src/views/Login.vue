<template>
  <div class="auth-page">
    <div class="auth-container">
      <div class="auth-card">
        <!-- Logo -->
        <div class="logo-container">
          <img src="/cycure.png" alt="CyCure Logo" class="cycure-logo" />
        </div>

        <h2>Login</h2>

        <form @submit.prevent="handleLogin" class="auth-form">
          <div class="form-group">
            <label for="email">Email</label>
            <input
                type="email"
                id="email"
                v-model="form.email"
                required
                class="form-input"
            />
          </div>

          <div class="form-group">
            <label for="password">Password</label>
            <input
                type="password"
                id="password"
                v-model="form.password"
                required
                class="form-input"
            />
          </div>

          <button type="submit" class="btn btn-primary" :disabled="loading">
            {{ loading ? 'Logging in...' : 'Login' }}
          </button>
        </form>

        <div v-if="error" class="error-message">
          {{ error }}
        </div>

        <div class="auth-footer">
          <p>Don't have an account? <router-link to="/register">Register here</router-link></p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import apiService from '../services/apiService'
import { isLoggedIn, currentUser } from '../../auth.js'

export default {
  name: 'Login',
  setup() {
    const router = useRouter()
    const loading = ref(false)
    const error = ref('')

    const form = ref({
      email: '',
      password: ''
    })

    const handleLogin = async () => {
      loading.value = true
      error.value = ''

      try {
        const response = await apiService.login(form.value)
        if (response.success) {
          isLoggedIn.value = true
          currentUser.value = response.user
          router.push('/')
        } else {
          error.value = response.message
        }
      } catch (err) {
        error.value = err.response?.data?.message || 'Login failed'
      } finally {
        loading.value = false
      }
    }

    return {
      form,
      loading,
      error,
      handleLogin
    }
  }
}
</script>

<style scoped>
.auth-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 60vh; /* samma som register */
}

.auth-card {
  background: #161B22; /* dark mode card */
  color: #E6EDF3;      /* dark mode text */
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 255, 179, 0.2);
  width: 100%;
  max-width: 400px;    /* matchar register */
  text-align: center;
}

.logo-container {
  display: flex;
  justify-content: center;
  margin-bottom: 1rem;
}

.cycure-logo {
  width: 180px;
  height: auto;
  filter: drop-shadow(0 0 15px rgba(0, 163, 255, 0.8));
}

.auth-card h2 {
  color: #00A3FF; /* dark mode heading */
  margin-bottom: 2rem;
  font-size: 1.8rem;
  text-shadow: 0 0 10px rgba(0, 163, 255, 0.3);
}

.auth-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.form-group {
  text-align: left;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  color: #E6EDF3; /* dark mode label */
  font-weight: 600;
  font-size: 0.9rem;
}

.form-input {
  width: 100%;
  padding: 0.8rem;
  border: 1px solid #21262D;
  border-radius: 8px;
  background-color: #161B22; /* dark mode input */
  color: #E6EDF3;
  font-size: 1rem;
}

.form-input:focus {
  outline: none;
  border-color: #00A3FF;
  box-shadow: 0 0 10px rgba(0, 163, 255, 0.4);
}

.btn {
  width: 100%;
  padding: 0.9rem;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 700;
  transition: all 0.3s ease;
}

.btn-primary {
  background: linear-gradient(135deg, #00A3FF, #00FFB3);
  color: #0D1117;
  box-shadow: 0 0 10px rgba(0, 255, 179, 0.4);
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 0 16px rgba(0, 255, 179, 0.7);
}

.btn:disabled {
  background-color: #3A3F47;
  cursor: not-allowed;
  opacity: 0.6;
}

.error-message {
  background: linear-gradient(135deg, #FF4C4C, #C62828);
  color: white;
  padding: 0.75rem;
  border-radius: 8px;
  margin-top: 1rem;
  text-align: center;
  box-shadow: 0 0 10px rgba(255, 76, 76, 0.4);
}

.success-message {
  background-color: #27ae60;
  color: #0D1117;
  padding: 0.75rem;
  border-radius: 8px;
  margin-top: 1rem;
  text-align: center;
}

.auth-footer {
  text-align: center;
  color: #8B949E;
  margin-top: 1.5rem;
  font-size: 0.95rem;
}

.auth-footer a {
  color: #00A3FF;
  font-weight: 600;
  text-decoration: none;
}

.auth-footer a:hover {
  text-shadow: 0 0 8px rgba(0, 163, 255, 0.5);
}
</style>

