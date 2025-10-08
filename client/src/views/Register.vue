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
  background: white;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  width: 100%;
  max-width: 400px;
}

.auth-card h2 {
  text-align: center;
  color: #2c3e50;
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
  color: #2c3e50;
  font-weight: bold;
}

.form-input {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

.form-input:focus {
  outline: none;
  border-color: #3498db;
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
  background-color: #3498db;
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background-color: #2980b9;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.error-message {
  background-color: #e74c3c;
  color: white;
  padding: 0.75rem;
  border-radius: 4px;
  margin-bottom: 1rem;
  text-align: center;
}

.success-message {
  background-color: #27ae60;
  color: white;
  padding: 0.75rem;
  border-radius: 4px;
  margin-bottom: 1rem;
  text-align: center;
}

.auth-footer {
  text-align: center;
  color: #7f8c8d;
}

.auth-footer a {
  color: #3498db;
  text-decoration: none;
}

.auth-footer a:hover {
  text-decoration: underline;
}
</style>
