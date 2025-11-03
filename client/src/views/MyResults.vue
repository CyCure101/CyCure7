<template>
  <div class="results-page">
    <!-- Progress Bar & Header -->
    <div class="progress-header-container">
      <div class="progress-overview-header">
        <h2>Your Progress</h2>
      </div>
      <button @click="showResetModal = true" class="btn-progress-reset" title="Reset your progress">
        🔄 Reset Progress
      </button>
    </div>

    <div class="progress-bar-container">
      <!-- Fixed: The inner progress bar now uses a dynamic CSS variable. -->
      <div class="progress-bar" :style="{ width: overallPercentage + '%' }"></div>
      <div class="progress-text-overlay">{{ overallPercentage }}%</div>
    </div>

    <!-- Two-column layout: main + aside -->
    <div class="content-grid">
      <!-- Main: My Quiz Attempts -->
      <div class="main-content">
        <div v-if="loading" class="loading">
          <p>Loading your quiz results...</p>
        </div>

        <div v-else-if="!results.length" class="error">
          <h2>No Results Found</h2>
          <p>You haven't completed any quizzes yet.</p>
          <button class="btn btn-primary" @click="$router.push('/')">Take a Quiz</button>
        </div>

        <div v-else class="results-card">
          <h1>My Quiz Attempts</h1>
          <table class="results-table">
            <thead>
            <tr>
              <th>Attempt</th>
              <th>Quiz</th>
              <th>Score</th>
              <th>Total</th>
              <th>Percentage</th>
              <th>Date</th>
            </tr>
            </thead>
            <tbody>
            <!-- Fixed: Using dynamic classes for table rows/cells for better theming -->
            <tr v-for="result in results" :key="result.attemptId">
              <td>{{ result.attemptId }}</td>
              <td>{{ result.quizTitle }}</td>
              <td>{{ result.score }}</td>
              <td>{{ result.total }}</td>
              <td>{{ result.percentage }}%</td>
              <td>{{ formatDate(result.date) }}</td>
            </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Aside: Your Progress cards -->
      <aside class="aside-content">
        <div class="progress-overview">
          <div class="progress-stats">
            <div class="stat-card">
              <div class="stat-value">{{ completedTheoryCount }}</div>
              <div class="stat-label">Theories Completed</div>
            </div>
            <div class="stat-card">
              <div class="stat-value">{{ completedQuizzesCount }}</div>
              <div class="stat-label">Quizzes Completed</div>
            </div>
            <div class="stat-card">
              <div class="stat-value">{{ overallPercentage }}%</div>
              <div class="stat-label">Overall Progress</div>
            </div>
            <div class="stat-card">
              <div class="stat-value">{{ totalAttempts }}</div>
              <div class="stat-label">Total Attempts</div>
            </div>
          </div>
        </div>
      </aside>
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
import { ref, computed, onMounted } from 'vue'
import apiService from '../services/apiService'
import { currentUser } from '../../auth'

export default {
  name: 'MyResults',
  setup() {
    const quizzes = ref([])
    const results = ref([])
    const completedTheory = ref({})
    const completedQuizzes = ref({})
    const loading = ref(true)
    const showResetModal = ref(false)

    const completedTheoryCount = computed(() =>
        Object.values(completedTheory.value).filter(Boolean).length
    )
    const completedQuizzesCount = computed(() =>
        Object.values(completedQuizzes.value).filter(Boolean).length
    )
    const overallPercentage = computed(() =>
        quizzes.value.length
            ? Math.round((completedQuizzesCount.value / quizzes.value.length) * 100)
            : 0
    )
    const totalAttempts = computed(() => results.value.length)

    const formatDate = (dateStr) => {
      const d = new Date(dateStr)
      return d.toLocaleString()
    }

    const fetchQuizzes = async () => {
      const response = await apiService.getQuizzes()
      quizzes.value = response.quizzes || []
    }

    const fetchUserProgress = async () => {
      const userId = currentUser.value?.id
      if (!userId) return
      const response = await apiService.getUserProgress(userId)
      if (response.success) {
        completedTheory.value = {}
        completedQuizzes.value = {}
        response.progress.forEach((item) => {
          completedTheory.value[item.quiz_id] = !!item.theory_completed
          completedQuizzes.value[item.quiz_id] = !!item.quiz_completed
        })
      }
    }

    const fetchUserAttempts = async () => {
      const userId = currentUser.value?.id
      if (!userId) return
      const data = await apiService.getUserAttempts(userId)
      results.value = data?.attempts.map(a => ({
        attemptId: a.attempt_id,
        quizTitle: a.quiz_title || 'Unknown Quiz',
        score: a.score,
        total: a.total_questions,
        percentage: a.total_questions ? Math.round((a.score / a.total_questions) * 100) : 0,
        date: a.completed_at
      })) || []
    }

    const fetchAllData = async () => {
      loading.value = true
      try {
        await fetchQuizzes()
        await fetchUserProgress()
        await fetchUserAttempts()
      } catch (err) {
        console.error(err)
      } finally {
        loading.value = false
      }
    }

    const resetProgress = async () => {
      try {
        const userId = currentUser.value?.id
        if (!userId) {
          console.error('You must be logged in to reset progress.')
          showResetModal.value = false
          return
        }

        const response = await apiService.resetUserProgress(userId)

        if (response.success) {
          // Uppdatera lokalt state
          completedTheory.value = {}
          completedQuizzes.value = {}
          results.value = []
          showResetModal.value = false

          // Tvinga uppdatering av data
          await fetchUserProgress()
          await fetchUserAttempts()

          // I en riktig app skulle man visa en notis här
          console.log('✅ Progress reset successfully!')
        } else {
          console.error('❌ Failed to reset: ' + (response.message || 'Unknown error'))
        }
      } catch (error) {
        console.error('Network error:', error)
      }
    }


    onMounted(fetchAllData)

    return {
      results,
      completedTheoryCount,
      completedQuizzesCount,
      overallPercentage,
      totalAttempts,
      loading,
      showResetModal,
      formatDate,
      resetProgress
    }
  }
}
</script>

<style scoped>
/* ========================================================================= */
/* --- 1. CORE LAYOUT & THEME VARIABLES --- */
/* ========================================================================= */

.results-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
  color: var(--color-text); /* Dynamisk textfärg */
}

/* --- PROGRESS BAR HEADER (FÖR KNAPPEN) --- */
.progress-header-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.8rem;
}

/* --- PROGRESS BAR --- */
.progress-bar-container {
  background: var(--color-bg-progress-container); /* Dynamisk bakgrund */
  border-radius: 12px;
  height: 40px;
  margin-bottom: 2rem;
  overflow: hidden;
  position: relative;
  box-shadow: 0 4px 10px var(--color-shadow-progress-bar);
  border: 1px solid var(--color-border-progress-bar);
}
.progress-bar {
  /* FIX: Sätter den dynamiska färggradienten här så att fältet fylls korrekt. */
  background: var(--color-gradient-progress-bar);
  height: 100%;
  transition: width 1s ease-out;
}
.progress-text-overlay {
  position: absolute;
  inset: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  font-weight: 700;
  color: var(--color-text-overlay); /* Dynamisk textfärg */
  text-shadow: 0 0 2px rgba(0, 0, 0, 0.5);
}

/* --- TWO-COLUMN LAYOUT --- */
.content-grid {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 2rem;
}

/* --- MAIN CONTENT --- */
.main-content .results-card {
  background: var(--color-bg-card); /* Dynamisk bakgrund */
  border-radius: 12px;
  padding: 2rem;
  border: var(--color-border-card); /* Dynamisk kantlinje */
  box-shadow: 0 0 20px var(--color-shadow-card);
  height: 100%;
}

/* --- ASIDE CONTENT (PROGRESS STATS) --- */
.aside-content {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  height: 100%;
}
.progress-overview {
  background: var(--color-bg-card); /* Dynamisk bakgrund */
  border-radius: 16px;
  padding: 1.5rem;
  border: var(--color-border-card); /* Dynamisk kantlinje */
  height:100%;
}
.progress-stats {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}
.stat-card {
  background: var(--color-bg-stat-card); /* Dynamisk bakgrund */
  border-radius: 12px;
  padding: 1rem;
  text-align: center;
  transition: all 0.3s ease;
}
.stat-value {
  font-size: 2rem;
  font-weight: 700;
  color: var(--color-accent); /* Dynamisk accentfärg */
}
.stat-label {
  font-size: 0.9rem;
  color: var(--color-text-secondary); /* Dynamisk sekundär textfärg */
}

/* --- TABLE --- */
.results-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1.5rem;
  background: var(--color-bg-table); /* Dynamisk bakgrund */
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 4px 10px var(--color-shadow-table);
}
.results-table th,
.results-table td {
  padding: 0.75rem 1rem;
  /* FIX: Säkerställer att radavdelaren är dynamisk */
  border-bottom: 1px solid var(--color-border-table-row);
}
.results-table th {
  /* FIX: Säkerställer att header-gradienten och texten är dynamisk */
  background: var(--color-bg-table-header);
  color: var(--color-text-table-header);
  font-weight: 600;
  text-transform: uppercase;
  background-image: var(--color-gradient-table-header);
}
.results-table td {
  color: var(--color-text); /* Dynamisk textfärg */
  /* FIX: Säkerställer att cell-bakgrunden är dynamisk */
  background: var(--color-bg-table-cell);
}
.results-table tr:hover td {
  /* FIX: Säkerställer att hover-färgen är dynamisk */
  background: var(--color-bg-table-hover);
}

/* --- HEADERS OCH KNAPPAR --- */
.btn {
  padding: 0.6rem 1.25rem;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;
}
.btn-primary {
  background: var(--color-bg-btn-primary);
  color: var(--color-text-btn-primary);
}
.btn-primary:hover {
  background: var(--color-bg-btn-primary-hover);
}

.progress-overview-header h2 {
  font-size: 1.6rem;
  font-weight: 700;
  color: var(--color-accent-secondary);
  text-shadow: 0 0 8px var(--color-shadow-accent-secondary);
  margin: 0;
  letter-spacing: 0.5px;
}

/* Reset-knapp */
.btn-progress-reset {
  background: linear-gradient(135deg, #FF4C4C, #C62828); /* Håll den röd */
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 600;
  transition: all 0.3s ease;
  box-shadow: 0 0 10px rgba(255, 76, 76, 0.5);
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-progress-reset:hover {
  background: linear-gradient(135deg, #FF6B6B, #E53935);
  box-shadow: 0 0 18px rgba(255, 76, 76, 0.7);
  transform: translateY(-2px);
}

/* ========================================================================= */
/* --- 2. MODAL STYLES --- */
/* ========================================================================= */

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: var(--color-bg-modal-overlay);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  backdrop-filter: blur(4px);
  transition: background 0.3s ease;
}

.modal-content {
  position: relative;
  background: var(--color-bg-card);
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
  color: var(--color-text-modal-h2);
  margin-bottom: 1rem;
  font-size: 1.8rem;
  transition: color 0.3s ease;
}

.modal-content p {
  color: var(--color-text-modal-p);
  margin-bottom: 1rem;
  font-size: 1.1rem;
  transition: color 0.3s ease;
}

.warning-text {
  color: var(--color-text-modal-h2);
  font-weight: 600;
  margin-top: 1rem;
}

.reset-list {
  text-align: left;
  margin: 1rem 0;
  padding-left: 1.5rem;
}

.reset-list li {
  color: var(--color-text-card-p);
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
/* --- 3. RESPONSIVE --- */
/* ========================================================================= */

@media (max-width: 992px) {
  .content-grid {
    grid-template-columns: 1fr;
  }
  .progress-stats {
    flex-direction: row;
    flex-wrap: wrap;
    justify-content: space-between;
  }
  .stat-card {
    flex: 1 1 45%;
  }
}

@media (max-width: 768px) {
  .progress-header-container {
    flex-direction: column;
    align-items: flex-start;
  }
  .progress-overview-header {
    width: 100%;
  }
  .progress-header-container h2 {
    text-align: left;
    margin-bottom: 1rem;
  }
  .btn-progress-reset {
    width: 100%;
    justify-content: center;
    padding: 0.6rem;
  }
  .progress-stats {
    flex-direction: column;
  }
  .stat-card {
    flex: 1 1 100%;
  }
}

@media (max-width: 480px) {
  .progress-overview-header h2 {
    font-size: 1.2rem;
    margin-bottom: 0.5rem;
  }
  .progress-bar-container {
    height: 30px;
  }
}
</style>
