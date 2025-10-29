<template>
  <div class="home">
    <div class="hero">
      <div class="header-section">
        <div>
          <h1>Welcome to CyCure</h1>
          <p>Test your cybersecurity knowledge with our interactive quizzes</p>
        </div>
      </div>

      <!-- Overall Progress Card -->
      <div class="progress-overview" v-if="quizzes.length > 0">
        <div class="progress-header">
          <div class="header-placeholder"></div>
          <div class="header-title-container">
            <h2>📊 Your Progress</h2>
          </div>
          <button @click="showResetModal = true" class="btn-progress-reset" title="Reset your progress">
            🔄 Reset Progress
          </button>
        </div>
        <div class="progress-stats">
          <div class="stat-card">
            <div class="stat-info">
              <div class="stat-value">{{ completedTheoryCount }}</div>
              <div class="stat-label">Theories Completed</div>
            </div>
          </div>
          <div class="stat-card">
            <div class="stat-info">
              <div class="stat-value">{{ completedQuizzesCount }}</div>
              <div class="stat-label">Quizzes Completed</div>
            </div>
          </div>
          <div class="stat-card">
            <div class="stat-info">
              <div class="stat-value">{{ overallPercentage }}%</div>
              <div class="stat-label">Overall Progress</div>
            </div>
          </div>
          <div class="stat-card">
            <div class="stat-info">
              <div class="stat-value">{{ totalAttempts }}</div>
              <div class="stat-label">Total Attempts</div>
            </div>
          </div>
        </div>
        <div class="progress-overview" v-if="quizzes.length > 0">
          <div class="progress-bar-container">
            <div class="progress-bar" :style="{ width: overallPercentage + '%' }">
            </div>

            <div class="progress-text-overlay">
              {{ overallPercentage }}%
            </div>
          </div>
        </div>
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

    <!-- Diploma Modal -->
    <div v-if="showDiplomaModal" class="modal-overlay" @click="showDiplomaModal = false">
      <div class="modal-content diploma" @click.stop>
        <h2>🎓 Congratulations!</h2>
        <p>You have completed all quizzes and earned your CyCure Diploma.</p>
        <div class="diploma-badge">🏅</div>
        <div class="modal-actions">
          <button class="btn btn-primary" @click="showDiplomaModal = false">Awesome!</button>
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
import {ref, computed, onMounted, watch} from 'vue'
import {useRouter, useRoute} from 'vue-router'
import apiService from '../services/apiService'
import {isLoggedIn, currentUser} from '../../auth'

export default {
  setup() {
    const router = useRouter()
    const route = useRoute()
    const authChecked = ref(false)
    const quizzes = ref([])
    const loading = ref(true)
    const error = ref('')
    const completedTheory = ref({})
    const completedQuizzes = ref({})
    const showResetModal = ref(false)
    const userAttempts = ref([])
    const showDiplomaModal = ref(false)

    // --- 🧮 Computed ---
    const completedTheoryCount = computed(() =>
        Object.values(completedTheory.value).filter(Boolean).length
    )
    const completedQuizzesCount = computed(() =>
        Object.values(completedQuizzes.value).filter(Boolean).length)
    const overallPercentage = computed(() =>
        quizzes.value.length
            ? Math.round((completedQuizzesCount.value / quizzes.value.length) * 100)
            : 0
    )

    // Show diploma modal when all quizzes completed
    const allQuizzesCompleted = computed(() => quizzes.value.length > 0 && completedQuizzesCount.value === quizzes.value.length)

    const getDiplomaKey = () => {
      const id = currentUser.value?.id
      return id ? `diplomaShown_${id}` : 'diplomaShown_guest'
    }

    const checkDiploma = () => {
      if (allQuizzesCompleted.value) {
        const key = getDiplomaKey()
        if (!localStorage.getItem(key)) {
          showDiplomaModal.value = true
          localStorage.setItem(key, '1')
        }
      }
    }

    const totalAttempts = computed(() => userAttempts.value.length)
    const streakIcon = computed(() => {
      const count = totalAttempts.value
      if (count === 0) return '🌱'
      if (count < 5) return '🔥'
      if (count < 10) return '⚡'
      return '🏆'
    })

    // --- 🚀 Navigation ---
    const goToTheory = (quizId) => router.push(`/quiz/${quizId}/theory`)
    const startQuiz = (quizId) => {
      if (!completedTheory.value[quizId]) {
        alert('Please complete the theory first!')
        return
      }
      router.push(`/quiz/${quizId}`)
    }

    // --- 🧩 FETCH FUNCTIONS ---
    const fetchQuizzes = async () => {
      try {
        loading.value = true
        error.value = ''
        const response = await apiService.getQuizzes()
        quizzes.value = response.quizzes || []
      } catch (err) {
        error.value = 'Failed to load quizzes'
        console.error(err)
      } finally {
        loading.value = false
        authChecked.value = true
      }
    }

    const fetchUserAttempts = async () => {
      try {
        const userId = currentUser.value?.id
        if (userId) {
          const data = await apiService.getUserAttempts(userId)
          userAttempts.value = data?.attempts || []
        }
      } catch (err) {
        console.error(err)
      }
    }

    const fetchUserProgress = async () => {
      try {
        const userId = currentUser.value?.id
        if (!userId) return

        const response = await apiService.getUserProgress(userId)

        if (response.success) {
          const progress = response.progress || []
          completedTheory.value = {}
          completedQuizzes.value = {}
          progress.forEach((item) => {
            completedTheory.value[item.quiz_id] = !!item.theory_completed
            completedQuizzes.value[item.quiz_id] = !!item.quiz_completed
          })
        }
      } catch (err) {
        console.error('Error loading progress:', err)
      }
    }

    const resetProgress = async () => {
      try {
        const userId = currentUser.value?.id
        if (!userId) {
          alert('You must be logged in')
          return
        }

        const response = await apiService.resetUserProgress(userId)

        if (response.success) {
          completedTheory.value = {}
          completedQuizzes.value = {}
          showResetModal.value = false

          // Allow diploma to be earned again
          try { localStorage.removeItem(getDiplomaKey()) } catch (e) { /* ignore */ }

          await fetchUserProgress()
          await fetchUserAttempts()

          alert('✅ Progress reset successfully!')
        } else {
          alert('❌ Failed to reset: ' + (response.message || 'Unknown error'))
        }
      } catch (error) {
        console.error('Network error:', error)
        alert('❌ Network error: ' + error.message)
      }
    }

    // --- 👀 WATCHERS ---
    watch(
        isLoggedIn,
        async (val) => {
          if (val) {
            await fetchQuizzes()
            await fetchUserAttempts()
            await fetchUserProgress()
            checkDiploma()
          } else {
            router.replace('/login')
          }
        },
        {immediate: true}
    )

    watch(
        () => route.path,
        async (newPath) => {
          if (newPath === '/' && isLoggedIn.value) {
            await fetchUserProgress()
            await fetchUserAttempts()
            checkDiploma()
          }
        }
    )

    // --- 🏁 MOUNT ---
    onMounted(async () => {
      const userId = currentUser.value?.id
      if (userId) {
        await fetchUserProgress()
        checkDiploma()
      }
    })

    return {
      authChecked,
      quizzes,
      loading,
      error,
      completedTheory,
      completedQuizzes,
      showResetModal,
      showDiplomaModal,
      completedTheoryCount,
      completedQuizzesCount,
      overallPercentage,
      totalAttempts,
      streakIcon,
      goToTheory,
      startQuiz,
      resetProgress,
    }
  },
}
</script>
<style scoped>
/* ========================================================================= */
/* --- 1. CORE LAYOUT & TYPOGRAPHY --- */
/* ========================================================================= */

.home {
  text-align: center;
}

.hero {
  margin-bottom: 3rem;
}

/* Centrerar header-texten */
.header-section {
  display: flex;
  justify-content: center;
  flex-direction: column;
  align-items: center;
  margin-bottom: 2rem;
  gap: 0.5rem; /* Mindre gap för tightare text */
  width: 100%;
}

.hero h1 {
  font-size: 3rem;
  color: #2c3e50;
  margin-bottom: 0.5rem;
  text-align: center;
}

.hero p {
  font-size: 1.2rem;
  color: #7f8c8d;
  text-align: center;
  margin-bottom: 0;
}

/* Den gamla .btn-reset-stilen är borttagen härifrån */


/* ========================================================================= */
/* --- 2. PROGRESS OVERVIEW (KORTET) --- */
/* ========================================================================= */

.progress-overview {
  background: white;
  border-radius: 16px;
  padding: 2rem;
  margin: 2rem 0;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

/* FIX & STYLING: Progress Header med Reset-knapp */
.progress-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid #ecf0f1;
}


.header-placeholder {
  flex-basis: 150px; /* Samma bredd som knappen */
  opacity: 0;
  visibility: hidden;
}

.header-title-container {
  flex-grow: 1; /* Låter denna ta upp allt återstående utrymme */
  text-align: center;
}

.progress-header h2 {
  color: #2c3e50;
  font-size: 1.8rem;
  margin: 0;
}

.btn-progress-reset {
  flex-basis: 159px;
  display: flex;
  justify-content: flex-end;
  background: linear-gradient(135deg, #ff6b6b, #ee5a6f);
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.8rem;
  font-weight: 600;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(255, 107, 107, 0.3);
}

.btn-progress-reset:hover {
  background: linear-gradient(135deg, #d52c45, #ee5a6f);
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(213, 15, 15, 0.66);
}

/* Progress Stats Cards */
.progress-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}

.stat-card {
  background: linear-gradient(135deg, #f6f9fc 0%, #e9eff5 100%);
  border-radius: 12px;
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: 0.5rem;
  transition: all 0.3s ease;
  border: 2px solid transparent;
}

.stat-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
  border-color: #3498db;
}

.stat-value {
  font-size: 2.5rem;
  font-weight: 700;
  color: #2c3e50;
  line-height: 1;
  margin-bottom: 0.5rem;
}

.stat-label {
  font-size: 0.9rem;
  color: #7f8c8d;
  font-weight: 500;
}


/* Progress Bar */
.progress-bar-container {
  background: #e9ecef;
  border-radius: 12px;
  height: 40px;
  overflow: hidden;
  position: relative;
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.1);
}

.progress-bar {
  background: linear-gradient(135deg, #3498db 0%, #2ecc71 100%);
  height: 100%;
  transition: width 1s ease-out;
  position: relative;
  overflow: hidden;
}

.progress-bar::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(
      90deg,
      transparent,
      rgba(255, 255, 255, 0.3),
      transparent
  );
  animation: shimmer 2s infinite;
}

@keyframes shimmer {
  0% {
    transform: translateX(-100%);
  }
  100% {
    transform: translateX(100%);
  }
}

.progress-text-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 1.1rem;
  z-index: 2;
  color: #2c3e50;
  text-shadow: 0 0 2px rgba(255, 255, 255, 0.5);
}


/* ========================================================================= */
/* --- 3. QUIZ MODULES --- */
/* ========================================================================= */

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
  background-color: #2c791a;
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

/* ========================================================================= */
/* --- 4. MODAL & UTILITY --- */
/* ========================================================================= */

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
  position: relative;
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


/* ========================================================================= */
/* --- 5. RESPONSIVE --- */
/* ========================================================================= */

.diploma .diploma-badge {
  font-size: 3rem;
  margin: 1rem 0 0.5rem;
}

@media (max-width: 768px) {
  .header-section {
    flex-direction: column;
    text-align: center;
  }

  .hero h1 {
    font-size: 2rem;
  }

  /* Säkrar att progress-header staplar på mobil */
  .progress-header {
    flex-direction: column;
    align-items: center;
  }

  .progress-header h2 {
    margin-bottom: 0.75rem;
  }

  .quiz-actions {
    flex-direction: column;
  }

  .modal-content {
    padding: 1.5rem;
  }

  .progress-stats {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>
