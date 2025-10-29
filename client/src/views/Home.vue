<template>
  <div class="home">
    <div class="hero">
      <div class="header-section">
        <div>
          <h1>Welcome to CyCure</h1>
          <p>Test your cybersecurity knowledge with our interactive quizzes</p>
        </div>
      </div>
<!--
      Overall Progress Card
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

      -->

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
          }
        }
    )

    // --- 🏁 MOUNT ---
    onMounted(async () => {
      const userId = currentUser.value?.id
      if (userId) {
        await fetchUserProgress()
      }
    })

    return {
      authChecked,
      quizzes,
      loading,
      error,
      completedTheory,
      showResetModal,
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
  background-color: #0D1117; /* Night Code */
  color: #E6EDF3; /* Soft White */
  min-height: 100vh;
}

.hero {
  margin-bottom: 3rem;
}

.header-section {
  display: flex;
  justify-content: center;
  flex-direction: column;
  align-items: center;
  margin-bottom: 2rem;
  gap: 0.5rem;
  width: 100%;
}

.hero h1 {
  font-size: 3rem;
  color: #00A3FF; /* Cyber Blue */
  text-shadow: 0 0 12px rgba(0, 163, 255, 0.3);
  margin-bottom: 0.5rem;
}

.hero p {
  font-size: 1.2rem;
  color: #8B949E; /* Slate Gray */
  margin-bottom: 0;
}

/* ========================================================================= */
/* --- 2. PROGRESS OVERVIEW (KORTET) --- */
/* ========================================================================= */

.progress-overview {
  background: #161B22; /* Dark Panel */
  border-radius: 16px;
  padding: 2rem;
  margin: 2rem 0;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
  border: 1px solid #21262D; /* Graphite */
}

.progress-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid #21262D;
}

.header-placeholder {
  flex-basis: 150px;
  opacity: 0;
  visibility: hidden;
}

.header-title-container {
  flex-grow: 1;
  text-align: center;
}

.progress-header h2 {
  color: #00FFB3; /* Neon Green */
  font-size: 1.8rem;
  text-shadow: 0 0 10px rgba(0, 255, 179, 0.3);
  margin: 0;
}

.btn-progress-reset {
  flex-basis: 159px;
  display: flex;
  justify-content: flex-end;
  background: linear-gradient(135deg, #FF4C4C, #C62828);
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.8rem;
  font-weight: 600;
  transition: all 0.3s ease;
  box-shadow: 0 0 10px rgba(255, 76, 76, 0.5);
}

.btn-progress-reset:hover {
  background: linear-gradient(135deg, #FF6B6B, #E53935);
  box-shadow: 0 0 18px rgba(255, 76, 76, 0.7);
  transform: translateY(-2px);
}

/* Progress Stats Cards */
.progress-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}

.stat-card {
  background: #0D1117;
  border: 1px solid #21262D;
  border-radius: 12px;
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: 0.5rem;
  transition: all 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-5px);
  border-color: #00A3FF;
  box-shadow: 0 0 12px rgba(0, 163, 255, 0.4);
}

.stat-value {
  font-size: 2.5rem;
  font-weight: 700;
  color: #00FFB3; /* Neon Green */
  line-height: 1;
}

.stat-label {
  font-size: 0.9rem;
  color: #8B949E;
  font-weight: 500;
}

/* Progress Bar */
.progress-bar-container {
  background: #21262D;
  border-radius: 12px;
  height: 40px;
  overflow: hidden;
  position: relative;
}

.progress-bar {
  background: linear-gradient(90deg, #00A3FF, #00FFB3);
  height: 100%;
  transition: width 1s ease-out;
  box-shadow: 0 0 12px rgba(0, 255, 179, 0.4);
  position: relative;
}

.progress-bar::after {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  animation: shimmer 2s infinite;
}

@keyframes shimmer {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}

.progress-text-overlay {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 1.1rem;
  color: #E6EDF3;
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
  background: #161B22;
  border: 1px solid #21262D;
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 0 12px rgba(0, 0, 0, 0.5);
  transition: all 0.3s ease;
  position: relative;
}

.module-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 0 20px rgba(0, 163, 255, 0.3);
}

.module-card h3 {
  color: #00A3FF;
  margin-bottom: 1rem;
  font-size: 1.5rem;
}

.module-card p {
  color: #C9D1D9;
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
  background: #00A3FF;
  color: #fff;
  padding: 0.4rem 0.8rem;
  border-radius: 6px;
  font-weight: 600;
  text-transform: uppercase;
  font-size: 0.75rem;
}

.question-count {
  color: #8B949E;
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

/* --- Primary Button --- */
.btn-primary {
  background: linear-gradient(135deg, #00A3FF, #00FFB3);
  color: #0D1117;
  font-weight: 700;
  box-shadow: 0 0 8px rgba(0, 255, 179, 0.3);
}

.btn-primary:hover:not(:disabled) {
  box-shadow: 0 0 16px rgba(0, 255, 179, 0.6);
  transform: translateY(-2px);
}

/* --- Secondary Button --- */
.btn-secondary {
  background: #6C63FF;
  color: white;
}

.btn-secondary:hover {
  background: #7E72FF;
  box-shadow: 0 0 10px rgba(108, 99, 255, 0.4);
  transform: translateY(-2px);
}

.btn:disabled {
  background-color: #3A3F47;
  cursor: not-allowed;
  opacity: 0.6;
}

/* Progress Badge */
.progress-badge {
  background: linear-gradient(135deg, #00FFB3, #00A36C);
  color: #0D1117;
  padding: 0.5rem;
  border-radius: 6px;
  font-size: 0.85rem;
  font-weight: 600;
  margin-top: 0.5rem;
  box-shadow: 0 0 10px rgba(0, 255, 179, 0.3);
}

/* ========================================================================= */
/* --- 4. MODAL & UTILITY --- */
/* ========================================================================= */

.loading, .error {
  padding: 2rem;
  font-size: 1.1rem;
}

.loading { color: #00A3FF; }
.error { color: #FF4C4C; }

.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(13, 17, 23, 0.9);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  backdrop-filter: blur(6px);
}

.modal-content {
  background: #161B22;
  border: 1px solid #21262D;
  padding: 2.5rem;
  border-radius: 16px;
  max-width: 500px;
  width: 90%;
  box-shadow: 0 0 25px rgba(0, 163, 255, 0.3);
  animation: slideIn 0.3s ease-out;
  color: #E6EDF3;
}

.modal-content h2 {
  color: #FF4C4C;
}

.modal-content p {
  color: #E6EDF3;
}

.warning-text {
  color: #FF4C4C;
  font-weight: 600;
}

.reset-list li {
  color: #8B949E;
}

.btn-cancel {
  flex: 1;
  background: #21262D;
  color: #E6EDF3;
  border: 1px solid #3A3F47;
}

.btn-cancel:hover {
  background: #2A313A;
}

.btn-danger {
  flex: 1;
  background: linear-gradient(135deg, #FF4C4C, #C62828);
  color: white;
  font-weight: 600;
}

.btn-danger:hover {
  box-shadow: 0 0 15px rgba(255, 76, 76, 0.6);
  transform: translateY(-2px);
}

/* ========================================================================= */
/* --- 5. RESPONSIVE --- */
/* ========================================================================= */

@media (max-width: 768px) {
  .progress-header {
    flex-direction: column;
    align-items: center;
  }
  .progress-stats {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>

