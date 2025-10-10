<template>
  <div class="home">
    <div class="hero">
      <div class="header-section">
        <div>
          <h1>Welcome to CyCure</h1>
          <p>Test your cybersecurity knowledge with our interactive quizzes</p>
        </div>
        <button @click="showResetModal = true" class="btn-reset" title="Reset your progress">
          🔄 Reset Progress
        </button>
      </div>

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
          <div class="quiz-actions">
            <!-- Read Theory Button -->
            <button
                @click="goToTheory(quiz.id)"
                class="btn btn-secondary"
            >
              📖 Read Theory
            </button>
            <!-- Start Quiz Button -->
            <button
                @click="startQuiz(quiz.id)"
                class="btn btn-primary"
                :disabled="!completedTheory[quiz.id]"
            >
              {{ completedTheory[quiz.id] ? '▶️ Start Quiz' : '🔒 Locked' }}
            </button>
          </div>
          <!-- Progress indicator -->
          <div v-if="completedTheory[quiz.id]" class="progress-badge">
            ✅ Theory Completed
          </div>
        </div>
      </div>
    </div>

    <!-- Reset Confirmation Modal -->
    <div v-if="showResetModal" class="modal-overlay" @click="showResetModal = false">
      <div class="modal-content" @click.stop>
        <h2>⚠️ Reset Progress</h2>
        <p>Are you sure you want to reset your progress?</p>
        <p class="warning-text">This will:</p>
        <ul class="reset-list">
          <li>🔒 Lock all quizzes</li>
          <li>📚 Reset all completed theories</li>
          <li>📊 Clear all quiz results</li>
        </ul>
        <p class="warning-text"><strong>This action cannot be undone!</strong></p>
        <div class="modal-actions">
          <button @click="showResetModal = false" class="btn btn-cancel">
            Cancel
          </button>
          <button @click="resetProgress" class="btn btn-danger">
            Yes, Reset Everything
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import {ref, onMounted} from 'vue'
import {useRouter} from 'vue-router'
import apiService from '../services/apiService'
import {isLoggedIn} from '../../auth'

export default {
  name: 'Home',
  setup() {
    const router = useRouter()
    const quizzes = ref([])
    const loading = ref(true)
    const error = ref('')
    const completedTheory = ref({})
    const showResetModal = ref(false)

    // 🔐 Authentication Check
    if (!isLoggedIn.value) {
      router.replace('/login')
      return {}
    }

    // 📦 Hämta quiz-data från backend
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

    // 🚀 Navigera till teori
    const goToTheory = (quizId) => {
      router.push(`/quiz/${quizId}/theory`)
    }

    const startQuiz = (quizId) => {
      if (!completedTheory.value[quizId]) {
        alert('Please complete the theory section first!')
        return
      }
      router.push(`/quiz/${quizId}`)
    }

    // 🔄 Reset Progress
    const resetProgress = () => {
      // Clear completed theory
      localStorage.removeItem('completedTheory')
      completedTheory.value = {}

      // Clear quiz results (if you store them)
      localStorage.removeItem('quizResults')

      // Close modal
      showResetModal.value = false

      // Show success message
      alert('✅ Progress reset successfully! All quizzes are now locked.')
    }

    onMounted(() => {
      fetchQuizzes()
      const saved = JSON.parse(localStorage.getItem('completedTheory') || '{}')
      completedTheory.value = saved
    })

    return {
      quizzes,
      loading,
      error,
      goToTheory,
      startQuiz,
      completedTheory,
      showResetModal,
      resetProgress
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

.header-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  flex-wrap: wrap;
  gap: 1rem;
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

.btn-reset {
  background: linear-gradient(135deg, #ff6b6b, #ee5a6f);
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 600;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(255, 107, 107, 0.3);
}

.btn-reset:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(255, 107, 107, 0.4);
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
  border-radius: 12px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  position: relative;
}

.module-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.module-card h3 {
  color: #2c3e50;
  margin-bottom: 1rem;
  font-size: 1.5rem;
}

.module-card p {
  color: #7f8c8d;
  margin-bottom: 1rem;
  line-height: 1.6;
}

.quiz-info {
  display: flex;
  justify-content: space-between;
  margin-bottom: 1.5rem;
  font-size: 0.9rem;
}

.quiz-type {
  background-color: #3498db;
  color: white;
  padding: 0.4rem 0.8rem;
  border-radius: 6px;
  font-weight: 600;
  text-transform: uppercase;
  font-size: 0.75rem;
}

.question-count {
  color: #7f8c8d;
  font-weight: 500;
}

.quiz-actions {
  display: flex;
  gap: 0.75rem;
  margin-bottom: 1rem;
}

.btn {
  flex: 1;
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.95rem;
  font-weight: 600;
  transition: all 0.3s ease;
}

.btn-primary {
  background-color: #3498db;
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background-color: #2980b9;
  transform: translateY(-2px);
}

.btn-secondary {
  background-color: #266c01;
  color: white;
}

.btn-secondary:hover {
  background-color: #25570d;
  transform: translateY(-2px);
}

.btn:disabled {
  background-color: #bdc3c7;
  cursor: not-allowed;
  opacity: 0.6;
}

.progress-badge {
  background: linear-gradient(135deg, #2ecc71, #27ae60);
  color: white;
  padding: 0.5rem;
  border-radius: 6px;
  font-size: 0.85rem;
  font-weight: 600;
  margin-top: 0.5rem;
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

/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  backdrop-filter: blur(4px);
}

.modal-content {
  background: white;
  padding: 2.5rem;
  border-radius: 16px;
  max-width: 500px;
  width: 90%;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  animation: slideIn 0.3s ease-out;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(-30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.modal-content h2 {
  color: #e74c3c;
  margin-bottom: 1rem;
  font-size: 1.8rem;
}

.modal-content p {
  color: #2c3e50;
  margin-bottom: 1rem;
  font-size: 1.1rem;
}

.warning-text {
  color: #e74c3c;
  font-weight: 600;
  margin-top: 1rem;
}

.reset-list {
  text-align: left;
  margin: 1rem 0;
  padding-left: 1.5rem;
}

.reset-list li {
  color: #7f8c8d;
  margin: 0.5rem 0;
  font-size: 0.95rem;
}

.modal-actions {
  display: flex;
  gap: 1rem;
  margin-top: 2rem;
}

.btn-cancel {
  flex: 1;
  background-color: #95a5a6;
  color: white;
}

.btn-cancel:hover {
  background-color: #7f8c8d;
}

.btn-danger {
  flex: 1;
  background: linear-gradient(135deg, #e74c3c, #c0392b);
  color: white;
}

.btn-danger:hover {
  background: linear-gradient(135deg, #c0392b, #a93226);
  transform: translateY(-2px);
}

/* Responsive */
@media (max-width: 768px) {
  .header-section {
    flex-direction: column;
    text-align: center;
  }

  .hero h1 {
    font-size: 2rem;
  }

  .quiz-actions {
    flex-direction: column;
  }

  .modal-content {
    padding: 1.5rem;
  }
}
</style>
