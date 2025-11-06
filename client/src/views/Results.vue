<template>
  <div class="results-container">
    <div v-if="!hasData" class="error">
      <h2>Results Not Available</h2>
      <p>
        We couldn't find the results to display. This can happen if you refreshed the page.
      </p>
      <div class="actions">
        <button class="btn btn-primary" @click="$router.push('/')">Go to Home</button>
        <button class="btn btn-secondary" @click="goBackToQuiz">Retake Quiz</button>
      </div>
    </div>

    <div v-else class="results-card">
      <h1>Quiz Results</h1>
      <div class="summary">
        <div class="metric">
          <span class="label">Attempt ID</span>
          <span class="value">{{ attemptId }}</span>
        </div>
        <div class="metric">
          <span class="label">Score</span>
          <span class="value">{{ score }} / {{ total }}</span>
        </div>
        <div class="metric">
          <span class="label">Correct Answers</span>
          <span class="value">{{ correct }}</span>
        </div>
        <div class="metric">
          <span class="label">Percentage</span>
          <span class="value">{{ percentage }}%</span>
        </div>
      </div>

      <div class="actions">
        <button class="btn btn-primary" @click="$router.push('/')">Back to Home</button>
        <button class="btn btn-secondary" @click="goBackToQuiz">Retake Quiz</button>
      </div>
    </div>
  </div>
</template>
<script>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'

export default {
  name: 'Results',
  setup() {
    const route = useRoute()
    const router = useRouter()

    const attemptId = computed(() => route.params.attemptId)
    const score = computed(() => parseInt(route.query.score ?? 'NaN'))
    const total = computed(() => parseInt(route.query.total ?? 'NaN'))
    const correct = computed(() => parseInt(route.query.correct ?? 'NaN'))

    const hasData = computed(() => {
      return !Number.isNaN(score.value) && !Number.isNaN(total.value) && !Number.isNaN(correct.value)
    })

    const percentage = computed(() => {
      if (!hasData.value || total.value === 0) return 0
      return Math.round((score.value / total.value) * 100)
    })

    const goBackToQuiz = () => {
      const quizId = route.params.id
      router.push(`/quiz/${quizId}`)
    }

    return { attemptId,   score, total, correct, percentage, hasData, goBackToQuiz }
  }
}
</script>
<style scoped>
.results-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
  color: #E6EDF3; /* Soft White */
}

/* --- CARD / WRAPPER --- */
.results-card,
.error,
.loading {
  background: #161B22; /* Dark Panel */
  border-radius: 12px;
  padding: 2rem;
  box-shadow: 0 0 20px rgba(0, 163, 255, 0.15);
  text-align: center;
  border: 1px solid #21262D;
}

/* --- PROGRESS / SUMMARY METRICS --- */
.summary {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 1rem;
  margin: 1.5rem 0 2rem;
}

.metric {
  background: #0D1117;
  padding: 1rem;
  border-radius: 12px;
  text-align: center;
  box-shadow: 0 0 12px rgba(0, 255, 179, 0.2);
  transition: all 0.3s ease;
}
.metric:hover {
  transform: translateY(-4px);
  box-shadow: 0 0 20px rgba(0, 255, 179, 0.4);
}

.label {
  display: block;
  color: #8B949E;
  font-size: 0.85rem;
  margin-bottom: 0.25rem;
  font-weight: 500;
}

.value {
  font-size: 1.8rem;
  color: #00FFB3;
  font-weight: 700;
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
  transition: background 0.3s ease;
}
.results-table tr:hover td {
  background: rgba(0, 255, 179, 0.08);
}

/* --- BUTTONS --- */
.actions {
  margin-top: 2rem;
  display: flex;
  justify-content: center;
  gap: 1rem;
}

.btn {
  padding: 0.75rem 1.25rem;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 600;
  transition: all 0.3s ease;
}

.btn-primary {
  background: linear-gradient(135deg, #00A3FF, #00FFB3);
  color: #0D1117;
  box-shadow: 0 0 10px rgba(0, 255, 179, 0.3);
}
.btn-primary:hover {
  background: linear-gradient(135deg, #00FFB3, #00A3FF);
  transform: translateY(-2px);
  box-shadow: 0 0 20px rgba(0, 255, 179, 0.5);
}

.btn-secondary {
  background: #6C63FF;
  color: #fff;
}
.btn-secondary:hover {
  background: #7E72FF;
  box-shadow: 0 0 12px rgba(108, 99, 255, 0.4);
  transform: translateY(-2px);
}

/* --- STATES --- */
.error {
  border-left: 4px solid #FF4C4C;
  color: #FF6B6B;
}
.loading {
  border-left: 4px solid #00A3FF;
  color: #00A3FF;
}

/* --- RESPONSIVE --- */
@media (max-width: 992px) {
  .summary {
    grid-template-columns: repeat(2, 1fr);
  }
}
@media (max-width: 768px) {
  .summary {
    grid-template-columns: 1fr;
  }
  .results-table th,
  .results-table td {
    padding: 0.5rem;
  }
  .btn {
    font-size: 0.9rem;
    padding: 0.6rem 1rem;
  }
}

/* ========== RESPONSIVE ========== */

/* Tablets (max-width: 768px) */
@media (max-width: 768px) {
  .results-container {
    padding: 1.5rem;
  }

  .results-card h1 {
    font-size: 1.8rem;
  }

  .summary {
    grid-template-columns: 1fr;
    gap: 0.75rem;
  }

  .metric {
    padding: 0.9rem;
  }

  .value {
    font-size: 1.5rem;
  }

  .btn {
    font-size: 0.9rem;
    padding: 0.6rem 1.1rem;
  }
}

/* Mobiler (max-width: 480px) */
@media (max-width: 480px) {
  .results-container {
    padding: 1rem;
  }

  .results-card {
    padding: 1.5rem;
  }

  .results-card h1 {
    font-size: 1.4rem;
  }

  .summary {
    grid-template-columns: 1fr;
    gap: 0.75rem;
  }

  .metric {
    padding: 0.8rem;
    border-radius: 10px;
  }

  .label {
    font-size: 0.8rem;
  }

  .value {
    font-size: 1.3rem;
  }

  .actions {
    flex-direction: column;
    gap: 0.75rem;
  }

  .btn {
    width: 100%;
    font-size: 0.9rem;
    padding: 0.7rem;
  }

  .error h2 {
    font-size: 1.2rem;
  }

  .error p {
    font-size: 0.9rem;
  }
}

</style>
