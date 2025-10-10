<template>
  <div class="results-container">
    <!-- Loading State -->
    <div v-if="loading" class="loading">
      <p>Loading your quiz results...</p>
    </div>

    <!-- No Results -->
    <div v-else-if="!results.length" class="error">
      <h2>No Results Found</h2>
      <p>You haven't completed any quizzes yet.</p>
      <button class="btn btn-primary" @click="$router.push('/')">Take a Quiz</button>
    </div>

    <!-- Results Table -->
    <div v-else class="results-card">
      <h1>My Results</h1>
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

      <div class="actions">
        <button class="btn btn-primary" @click="$router.push('/')">Back to Home</button>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import apiService from '../services/apiService'
import { currentUser } from '../../auth'

export default {
  name: 'MyResults',
  setup() {
    const results = ref([])
    const loading = ref(true)

    const fetchResults = async () => {
      try {
        const userId = currentUser.value.id
        if (!userId) {
          console.warn('No logged-in user ID found')
          loading.value = false
          return
        }

        const data = await apiService.getUserAttempts(userId)
        if (!data?.success) {
          console.warn('Failed to fetch attempts:', data?.message)
          results.value = []
        } else {
          results.value = data.attempts.map(a => ({
            attemptId: a.attempt_id,
            quizTitle: a.quiz_title || 'Unknown Quiz',
            score: a.score,
            total: a.total_questions,
            percentage: a.total_questions ? Math.round((a.score / a.total_questions) * 100) : 0,
            date: a.completed_at
          }))
        }
      } catch (err) {
        console.error('Error fetching results:', err)
      } finally {
        loading.value = false
      }
    }

    const formatDate = (dateStr) => {
      const d = new Date(dateStr)
      return d.toLocaleString()
    }

    onMounted(fetchResults)

    return { results, loading, formatDate }
  }
}
</script>

<style scoped>
.results-container {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}

.results-card, .error, .loading {
  background: #fff;
  border-radius: 8px;
  padding: 2rem;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  text-align: center;
}

.results-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1.5rem;
}

.results-table th,
.results-table td {
  padding: 0.75rem;
  border-bottom: 1px solid #ddd;
}

.results-table th {
  background: #f8f9fa;
  color: #2c3e50;
}

.results-table td {
  color: #34495e;
}

.actions {
  margin-top: 1.5rem;
  display: flex;
  justify-content: center;
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
</style>

