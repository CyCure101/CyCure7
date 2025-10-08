<template>
  <div class="home">
    <div class="hero">
      <h1>Welcome to CyCure</h1>
      <p>Test your cybersecurity knowledge with our interactive quizzes</p>
      
      <div v-if="loading" class="loading">
        <p>Loading quizzes...</p>
      </div>
      
      <div v-else-if="error" class="error">
        <p>{{ error }}</p>
      </div>
      
      <div v-else class="quiz-modules">
        <div 
          v-for="quiz in quizzes" 
          :key="quiz.id" 
          class="module-card"
        >
          <h3>{{ quiz.title }}</h3>
          <p>{{ quiz.description }}</p>
          <div class="quiz-info">
            <span class="quiz-type">{{ quiz.module_type }}</span>
            <span class="question-count">{{ quiz.total_questions }} questions</span>
          </div>
          <button 
            @click="startQuiz(quiz.id)" 
            class="btn btn-primary"
            :disabled="quiz.total_questions === 0"
          >
            {{ quiz.total_questions === 0 ? 'Coming Soon' : 'Start Quiz' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import apiService from '../services/apiService'

export default {
  name: 'Home',
  setup() {
    const router = useRouter()
    const quizzes = ref([])
    const loading = ref(true)
    const error = ref('')

    const fetchQuizzes = async () => {
      try {
        loading.value = true
        error.value = ''
        const response = await apiService.getQuizzes()
        if (response.success) {
          quizzes.value = response.quizzes
        } else {
          error.value = 'Failed to load quizzes'
        }
      } catch (err) {
        error.value = 'Error loading quizzes: ' + (err.response?.data?.message || err.message)
      } finally {
        loading.value = false
      }
    }

    const startQuiz = (quizId) => {
      router.push(`/quiz/${quizId}`)
    }

    onMounted(() => {
      fetchQuizzes()
    })

    return {
      quizzes,
      loading,
      error,
      startQuiz
    }
  }
}
</script>

<style scoped>
.home {
  text-align: center;
}

.hero {
  margin-bottom: 3rem;
}

.hero h1 {
  font-size: 3rem;
  color: #2c3e50;
  margin-bottom: 1rem;
}

.hero p {
  font-size: 1.2rem;
  color: #7f8c8d;
  margin-bottom: 2rem;
}

.quiz-modules {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
  margin-top: 2rem;
}

.module-card {
  background: white;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  transition: transform 0.3s;
}

.module-card:hover {
  transform: translateY(-5px);
}

.module-card h3 {
  color: #2c3e50;
  margin-bottom: 1rem;
}

.module-card p {
  color: #7f8c8d;
  margin-bottom: 1rem;
}

.quiz-info {
  display: flex;
  justify-content: space-between;
  margin-bottom: 1.5rem;
  font-size: 0.9rem;
}

.quiz-type {
  background-color: #ecf0f1;
  color: #2c3e50;
  padding: 0.25rem 0.5rem;
  border-radius: 3px;
  font-weight: bold;
}

.question-count {
  color: #7f8c8d;
}

.btn {
  padding: 0.75rem 1.5rem;
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

.btn:disabled {
  background-color: #bdc3c7;
  cursor: not-allowed;
}

.loading, .error {
  padding: 2rem;
  font-size: 1.1rem;
}

.loading {
  color: #3498db;
}

.error {
  color: #e74c3c;
}
</style>
