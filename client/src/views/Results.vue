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
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem;
}

.results-card, .error {
  background: #fff;
  border-radius: 8px;
  padding: 2rem;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  text-align: center;
}

.summary {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
  margin: 1.5rem 0 2rem;
}

.metric {
  background: #f8f9fa;
  padding: 1rem;
  border-radius: 6px;
}

.label {
  display: block;
  color: #7f8c8d;
  font-size: 0.9rem;
  margin-bottom: 0.25rem;
}

.value {
  font-size: 1.2rem;
  color: #2c3e50;
  font-weight: 600;
}

.actions {
  display: flex;
  justify-content: center;
  gap: 1rem;
}

.btn {
  padding: 0.75rem 1.25rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
}

.btn-primary {
  background-color: #3498db;
  color: #fff;
}

.btn-secondary {
  background-color: #95a5a6;
  color: #fff;
}
</style>