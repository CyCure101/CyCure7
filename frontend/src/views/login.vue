<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();

// Reactive state for form inputs
const username = ref('');
const password = ref('');

function login() {
  const usernameInput = username.value;
  const passwordInput = password.value;

  if (usernameInput === "admin" && passwordInput === "admin123") {
    console.log("Admin login successful");
    router.push('/admin'); // redirect admins
  } else if (usernameInput === "user" && passwordInput === "user123") {
    console.log("User login successful");
    router.push('/main'); // redirect normal users
  } else {
    alert("Invalid credentials");
  }
}
</script>

<template>
  <!-- Center the entire login container on the screen -->
  <div class="login-page-container">
    <div class="login-card">
      <h2 class="form-title">Logga in på CyCure101</h2>

      <form @submit.prevent="login" class="login-form">
        <!-- Username Field -->
        <div class="input-group">
          <label for="username">Användarnamn</label>
          <input
              type="text"
              id="username"
              v-model="username"
              placeholder="Skriv in ditt användarnamn"
              required
          >
        </div>

        <!-- Password Field -->
        <div class="input-group">
          <label for="password">Lösenord</label>
          <input
              type="password"
              id="password"
              v-model="password"
              placeholder="Skriv in ditt lösenord"
              required
          >
        </div>

        <!-- Submit Button -->
        <button type="submit" class="login-btn">Logga in</button>
      </form>
    </div>
  </div>
</template>

<style scoped>
.login-page-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: calc(100vh - 56px);
  padding: 2rem;
  background-color: #f4f7f9;
}

.login-card {
  background: white;
  padding: 40px;
  border-radius: 12px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
  width: 100%;
  max-width: 400px;
  text-align: center;
}

.form-title {
  color: #333;
  margin-bottom: 25px;
  font-size: 1.5rem;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.input-group {
  text-align: left;
}

.input-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
  color: #555;
  font-size: 0.9rem;
}

.input-group input {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #ddd;
  border-radius: 6px;
  box-sizing: border-box;
  font-size: 1rem;
  transition: border-color 0.2s;
}

.input-group input:focus {
  border-color: #42b883;
  outline: none;
  box-shadow: 0 0 0 3px rgba(66, 184, 131, 0.2);
}

.login-btn {
  margin-top: 15px;
  padding: 12px 20px;
  background-color: #42b883;
  border: none;
  border-radius: 6px;
  color: white;
  font-weight: bold;
  cursor: pointer;
  transition: background-color 0.2s, transform 0.1s;
}

.login-btn:hover {
  background-color: #369c72;
  transform: translateY(-1px);
}
</style>
