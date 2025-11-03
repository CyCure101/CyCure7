<template>
  <div class="results-page">
    <!-- Progress Bar full width -->
    <div class="progress-overview-header">
    <h2>Your Progress</h2>
      </div>
    <div class="progress-bar-container">
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

    onMounted(fetchAllData)

    return {
      results,
      completedTheoryCount,
      completedQuizzesCount,
      overallPercentage,
      totalAttempts,
      loading,
      formatDate
    }
  }
}
</script>

<style scoped>
.results-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
  color: #E6EDF3;
}

/* --- PROGRESS BAR --- */
.progress-bar-container {
  background: #21262D;
  border-radius: 12px;
  height: 40px;
  margin-bottom: 2rem;
  overflow: hidden;
  position: relative;
}
.progress-bar {
  background: linear-gradient(90deg, #00A3FF, #00FFB3);
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
  color: #E6EDF3;
}

/* --- TWO-COLUMN LAYOUT --- */
.content-grid {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 2rem;
}

/* --- MAIN CONTENT --- */
.main-content .results-card {
  background: #161B22;
  border-radius: 12px;
  padding: 2rem;
  border: 1px solid #21262D;
  box-shadow: 0 0 20px rgba(0, 163, 255, 0.15);
  height: 100%;
}

/* --- ASIDE CONTENT --- */
.aside-content {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  height: 100%;
}
.progress-overview {
  background: #161B22;
  border-radius: 16px;
  padding: 1.5rem;
  border: 1px solid #21262D;
  height:100%;
}
.progress-stats {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}
.stat-card {
  background: #0D1117;
  border-radius: 12px;
  padding: 1rem;
  text-align: center;
}
.stat-value {
  font-size: 2rem;
  font-weight: 700;
  color: #00FFB3;
}
.stat-label {
  font-size: 0.9rem;
  color: #8B949E;
}

/* --- TABLE --- */
.results-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1.5rem;
  background: rgba(13, 17, 23, 0.8);
  border-radius: 8px;
  overflow: hidden;
}
.results-table th,
.results-table td {
  padding: 0.75rem 1rem;
  border-bottom: 1px solid #21262D;
}
.results-table th {
  background: linear-gradient(135deg, #00A3FF, #00FFB3);
  color: #0D1117;
  font-weight: 600;
  text-transform: uppercase;
}
.results-table td {
  color: #E6EDF3;
  background: rgba(22, 27, 34, 0.7);
}
.results-table tr:hover td {
  background: rgba(0, 255, 179, 0.08);
}

/* --- BUTTONS --- */
.btn {
  padding: 0.6rem 1.25rem;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
}
.btn-primary {
  background: linear-gradient(135deg, #00A3FF, #00FFB3);
  color: #0D1117;
}
.btn-primary:hover {
  background: linear-gradient(135deg, #00FFB3, #00A3FF);
}

.progress-overview-header h2 {
  font-size: 1.6rem;             /* Storlek på texten */
  font-weight: 700;              /* Fet stil */
  color: #00FFB3;                /* Neon Green */
  text-align: center;            /* Centrerad */
  text-shadow: 0 0 8px rgba(0, 255, 179, 0.3); /* Lätt glow */
  margin-bottom: 0.8rem;        /* Avstånd till progressbaren */
  letter-spacing: 0.5px;        /* Lite mellanrum mellan bokstäver */
}

/* --- RESPONSIVE --- */
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
  .progress-overview-header h2 {
    font-size: 1.4rem;
    margin-bottom: 0.6rem;
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

