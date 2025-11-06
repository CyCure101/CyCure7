<template>
  <div class="auth-container">
    <div class="auth-card">
      <h2>Register</h2>
      
      <form @submit.prevent="handleRegister" class="auth-form">
        <div class="form-group">
          <label for="username">Username:</label>
          <input 
            type="text" 
            id="username" 
            v-model="form.username" 
            required 
            class="form-input"
          />
        </div>
        
        <div class="form-group">
          <label for="email">Email:</label>
          <input 
            type="email" 
            id="email" 
            v-model="form.email" 
            required 
            class="form-input"
          />
        </div>
        
        <div class="form-group">
          <label for="password">Password:</label>
          <input 
            type="password" 
            id="password" 
            v-model="form.password" 
            required 
            class="form-input"
          />
        </div>
        
        <button type="submit" class="btn btn-primary" :disabled="loading">
          {{ loading ? 'Registering...' : 'Register' }}
        </button>
      </form>
      
      <div v-if="error" class="error-message">
        {{ error }}
      </div>
      
      <div v-if="success" class="success-message">
        {{ success }}
      </div>
      
      <div class="auth-footer">
        <p>Already have an account? <router-link to="/login">Login here</router-link></p>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import apiService from '../services/apiService'

export default {
  name: 'Register',
  setup() {
    const router = useRouter()
    const loading = ref(false)
    const error = ref('')
    const success = ref('')
    
    const form = ref({
      username: '',
      email: '',
      password: ''
    })

    const handleRegister = async () => {
      loading.value = true
      error.value = ''
      success.value = ''
      
      try {
        const response = await apiService.register(form.value)
        if (response.success) {
          success.value = 'Registration successful! You are now logged in.'
          setTimeout(() => {
            router.push('/')
          }, 1500)
        } else {
          error.value = response.message
        }
      } catch (err) {
        error.value = err.response?.data?.message || 'Registration failed'
      } finally {
        loading.value = false
      }
    }

    return {
      form,
      loading,
      error,
      success,
      handleRegister
    }
  }
}
</script>

<style scoped>
.auth-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 60vh;
}

.auth-card {
  background: #161B22; /* dark mode card */
  color: #E6EDF3;      /* dark mode text */
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 255, 179, 0.2);
  width: 100%;
  max-width: 400px;
}

.auth-card h2 {
  text-align: center;
  color: #00A3FF; /* dark mode heading */
  margin-bottom: 2rem;
}

.auth-form {
  margin-bottom: 1rem;
}

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  color: #E6EDF3; /* dark mode label */
  font-weight: bold;
}

.form-input {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #21262D; /* dark mode border */
  border-radius: 4px;
  font-size: 1rem;
  background: #161B22; /* dark mode background */
  color: #E6EDF3;      /* dark mode text */
}

.form-input:focus {
  outline: none;
  border-color: #00A3FF; /* highlight color */
}

.btn {
  width: 100%;
  padding: 0.75rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
  transition: background-color 0.3s;
}

.btn-primary {
  background: linear-gradient(135deg, #00A3FF, #00FFB3);
  color: #0D1117;
}

.btn-primary:hover:not(:disabled) {
  background: linear-gradient(135deg, #00FFB3, #00A3FF);
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.error-message {
  background-color: #FF4C4C;
  color: #0D1117;
  padding: 0.75rem;
  border-radius: 4px;
  margin-bottom: 1rem;
  text-align: center;
}

.success-message {
  background-color: #27ae60;
  color: #0D1117;
  padding: 0.75rem;
  border-radius: 4px;
  margin-bottom: 1rem;
  text-align: center;
}

.auth-footer {
  text-align: center;
  color: #8B949E;
}

.auth-footer a {
  color: #00A3FF;
  text-decoration: none;
}

.auth-footer a:hover {
  text-decoration: underline;
}
</style>
