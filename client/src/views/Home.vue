<template>
  <div class="home">
    <div class="hero">
      <div class="header-section">
        <div>
          <h1>Welcome to CyCure</h1>
          <p>Test your cybersecurity knowledge with our interactive quizzes</p>
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
          // OBS: Ersatt alert() med att sätta showDiplomaModal till true.
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
        // OBS: Ersatt alert() med console.error för att undvika fönster.alert
        console.error('Please complete the theory first!')
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
          console.error('You must be logged in to reset progress.')
          showResetModal.value = false; // Stäng modalen
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

          // I en riktig app skulle man visa en notis här istället för alert.
          console.log('✅ Progress reset successfully!')
        } else {
          console.error('❌ Failed to reset: ' + (response.message || 'Unknown error'))
        }
      } catch (error) {
        console.error('Network error:', error)
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
  /* Home-bakgrunden ärvs från body och hanteras i App.vue */
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
  gap: 0.5rem;
  width: 100%;
}

.hero h1 {
  font-size: 3rem;
  color: var(--color-text-h1-home); /* Dynamisk färg */
  margin-bottom: 0.5rem;
  text-align: center;
  /* Dark Mode Shadow */
  text-shadow: 0 0 12px rgba(0, 163, 255, 0.3);
  transition: color 0.3s ease;
}

.hero p {
  font-size: 1.2rem;
  color: var(--color-text-p-home); /* Dynamisk färg */
  text-align: center;
  margin-bottom: 0;
  transition: color 0.3s ease;
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
  background: var(--color-bg-card); /* Dynamisk färg */
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
  transition: all 0.3s ease;
  position: relative;
  border: var(--color-border-card); /* Dynamisk färg */
}

.module-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.3);
}

.module-card h3 {
  color: var(--color-text-card-h3); /* Dynamisk färg */
  margin-bottom: 1rem;
  font-size: 1.5rem;
  transition: color 0.3s ease;
}

.module-card p {
  color: var(--color-text-card-p); /* Dynamisk färg */
  margin-bottom: 1rem;
  line-height: 1.6;
  transition: color 0.3s ease;
}

.quiz-info {
  display: flex;
  justify-content: space-between;
  margin-bottom: 1.5rem;
  font-size: 0.9rem;
}

.quiz-type {
  background-color: var(--color-bg-quiz-type); /* Dynamisk färg */
  color: white;
  padding: 0.4rem 0.8rem;
  border-radius: 6px;
  font-weight: 600;
  text-transform: uppercase;
  font-size: 0.75rem;
  transition: background-color 0.3s ease;
}

.question-count {
  color: var(--color-text-question-count); /* Dynamisk färg */
  font-weight: 500;
  transition: color 0.3s ease;
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
  color: white;
}

.btn-primary {
  background: var(--color-bg-btn-primary); /* Dynamisk färg */
}

.btn-primary:hover:not(:disabled) {
  background: var(--color-bg-btn-primary-hover); /* Dynamisk färg */
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(0, 163, 255, 0.3);
}

.btn-secondary {
  background: var(--color-bg-btn-secondary); /* Dynamisk färg */
}


.btn-secondary:hover:not(:disabled) {
  background: var(--color-bg-btn-secondary-hover); /* Dynamisk färg */
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(46, 204, 113, 0.3);
}


.btn:disabled {
  background-color: #bdc3c7;
  cursor: not-allowed;
  opacity: 0.6;
}

.progress-badge {
  background: var(--color-bg-progress-badge); /* Dynamisk färg */
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
  transition: color 0.3s ease;
}

.loading {
  color: var(--color-loading);
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
  background: var(--color-bg-modal-overlay); /* Dynamisk färg */
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  backdrop-filter: blur(4px);
  transition: background 0.3s ease;
}

.modal-content {
  position: relative;
  background: var(--color-bg-card); /* Dynamisk färg */
  padding: 2.5rem;
  border-radius: 16px;
  max-width: 500px;
  width: 90%;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
  animation: slideIn 0.3s ease-out;
  border: var(--color-border-card);
  transition: background 0.3s ease;
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
  color: var(--color-text-modal-h2); /* Dynamisk färg */
  margin-bottom: 1rem;
  font-size: 1.8rem;
  transition: color 0.3s ease;
}

.modal-content p {
  color: var(--color-text-modal-p); /* Dynamisk färg */
  margin-bottom: 1rem;
  font-size: 1.1rem;
  transition: color 0.3s ease;
}

.warning-text {
  color: var(--color-text-modal-h2); /* Återanvänd färg */
  font-weight: 600;
  margin-top: 1rem;
}

.reset-list {
  text-align: left;
  margin: 1rem 0;
  padding-left: 1.5rem;
}

.reset-list li {
  color: var(--color-text-card-p); /* Dynamisk färg */
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



  .quiz-actions {
    flex-direction: column;
  }

  .modal-content {
    padding: 1.5rem;
  }


}

/* ---  RESPONSIVE MEDIA QUERIES --- */

/* --- Tablet (max-width: 768px) --- */
@media (max-width: 768px) {
  .hero h1 {
    font-size: 2.3rem;
  }

  .hero p {
    font-size: 1rem;
  }

  .quiz-modules {
    grid-template-columns: 1fr;
    gap: 1.5rem;
  }

  .module-card {
    padding: 1.5rem;
  }

  .quiz-actions {
    flex-direction: column;
    gap: 0.5rem;
  }

  .modal-content {
    padding: 1.5rem;
    width: 90%;
  }

  .modal-content h2 {
    font-size: 1.5rem;
  }

  .modal-content p {
    font-size: 1rem;
  }
}

/* --- Mobile (max-width: 480px) --- */
@media (max-width: 480px) {
  .hero h1 {
    font-size: 1.8rem;
    line-height: 1.2;
  }

  .hero p {
    font-size: 0.95rem;
    padding: 0 1rem;
  }

  .module-card {
    padding: 1rem;
  }

  .module-card h3 {
    font-size: 1.2rem;
  }

  .module-card p {
    font-size: 0.9rem;
  }

  .quiz-info {
    flex-direction: column;
    gap: 0.4rem;
    text-align: left;
  }

  .btn {
    font-size: 0.9rem;
    padding: 0.6rem 1rem;
  }

  .progress-badge {
    font-size: 0.8rem;
  }

  .modal-content {
    width: 95%;
    padding: 1.2rem;
  }

  .modal-actions {
    flex-direction: column;
  }

  .modal-actions button {
    width: 100%;
  }
}

</style>
