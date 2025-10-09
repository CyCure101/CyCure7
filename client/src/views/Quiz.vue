<template>
  <div class="quiz-container">
    <div v-if="loading" class="loading">
      <h2>Loading Quiz...</h2>
      <p>Please wait while we prepare your questions</p>
    </div>

    <div v-else-if="error" class="error">
      <h2>Error Loading Quiz</h2>
      <p>{{ error }}</p>
      <button @click="$router.push('/')" class="btn btn-primary">Back to Home</button>
    </div>

    <div v-else-if="!isLoggedIn" class="login-required">
      <h2>Login Required</h2>
      <p>You need to be logged in to take this quiz.</p>
      <button @click="$router.push('/login')" class="btn btn-primary">Login</button>
    </div>

    <div v-else class="quiz-content">
      <!-- Quiz Header -->
      <div class="quiz-header">
        <h1>{{ quiz.title }}</h1>
        <p>{{ quiz.description }}</p>
        <div class="quiz-progress">
          <div class="progress-bar">
            <div
              class="progress-fill"
              :style="{ width: progressPercentage + '%' }"
            ></div>
          </div>
          <span class="progress-text">
            Question {{ currentQuestionIndex + 1 }} of {{ questions.length }}
          </span>
        </div>
      </div>

      <!-- Question -->
      <div class="question-container">
        <div class="question-card">
          <h3 class="question-text">
            {{ currentQuestion.question_text }}
          </h3>

          <div class="answers-container">
            <div
              v-for="answer in currentQuestion.answers"
              :key="answer.id"
              class="answer-option"
              :class="{
                'selected': selectedAnswer === answer.id,
                'disabled': isSubmitting
              }"
              @click="selectAnswer(answer.id)"
            >
              <div class="answer-radio">
                <div
                  class="radio-circle"
                  :class="{ 'checked': selectedAnswer === answer.id }"
                ></div>
              </div>
              <div class="answer-text">{{ answer.answer_text }}</div>
            </div>
          </div>

          <div
              v-if="showFeedback"
              class="feedback-message"
              :class="{ correct: isCorrect, wrong: !isCorrect }"
          >
            <p>{{ isCorrect ? '✅ Correct!' : '❌ Wrong answer!' }}</p>
          </div>


          <!-- Navigation Buttons -->
          <div class="quiz-navigation">
            <button
              @click="previousQuestion"
              class="btn btn-secondary"
              :disabled="currentQuestionIndex === 0 || isSubmitting"
            >
              Previous
            </button>

            <button
              v-if="currentQuestionIndex < questions.length - 1"
              @click="nextQuestion"
              class="btn btn-primary"
              :disabled="!selectedAnswer || isSubmitting"
            >
              Next
            </button>

            <button
              v-else
              @click="submitQuiz"
              class="btn btn-success"
              :disabled="!selectedAnswer || isSubmitting"
            >
              {{ isSubmitting ? 'Submitting...' : 'Submit Quiz' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import apiService from '../services/apiService'

export default {
  name: 'Quiz',
  setup() {
    const route = useRoute()
    const router = useRouter()

    const quiz = ref({})
    const questions = ref([])
    const loading = ref(true)
    const error = ref('')
    const isLoggedIn = ref(false)
    const isSubmitting = ref(false)

    const showFeedback = ref(false)
    const isCorrect = ref(null)

    const currentQuestionIndex = ref(0)
    const selectedAnswer = ref(null)
    const userAnswers = ref({}) // Store all user answers

    const currentQuestion = computed(() => {
      return questions.value[currentQuestionIndex.value] || {}
    })

    const progressPercentage = computed(() => {
      return ((currentQuestionIndex.value + 1) / questions.value.length) * 100
    })

    const checkAuth = async () => {
      try {
        const response = await apiService.getCurrentUser()
        isLoggedIn.value = response.success
      } catch (error) {
        isLoggedIn.value = false
      }
    }

    const loadQuiz = async () => {
      try {
        loading.value = true
        error.value = ''

        const quizId = route.params.id

        // Load quiz details
        const quizResponse = await apiService.getQuiz(quizId)
        if (!quizResponse.success) {
          throw new Error(quizResponse.message || 'Failed to load quiz')
        }
        quiz.value = quizResponse.quiz

        // Load quiz questions
        const questionsResponse = await apiService.getQuizQuestions(quizId)
        if (!questionsResponse.success) {
          throw new Error(questionsResponse.message || 'Failed to load questions')
        }
        questions.value = questionsResponse.questions

        // Initialize user answers
        questions.value.forEach((question, index) => {
          userAnswers.value[question.id] = null
        })

      } catch (err) {
        error.value = err.response?.data?.message || err.message || 'Failed to load quiz'
      } finally {
        loading.value = false
      }
    }

    const selectAnswer = (answerId) => {
      if (isSubmitting.value || showFeedback.value) return

      selectedAnswer.value = answerId
      userAnswers.value[currentQuestion.value.id] = answerId

      // Find the selected answer object
      const answer = currentQuestion.value.answers.find(a => a.id === answerId)

      // Check if correct
      isCorrect.value = answer.is_correct === 1 || answer.is_correct === true
      showFeedback.value = true

      // Disable feedback after short delay (e.g. 1.5s) before moving on
      setTimeout(() => {
        showFeedback.value = false
        isCorrect.value = null
        if (currentQuestionIndex.value < questions.value.length - 1) {
          nextQuestion()
        }
      }, 1500)
    }

    const nextQuestion = () => {
      if (currentQuestionIndex.value < questions.value.length - 1) {
        currentQuestionIndex.value++
        selectedAnswer.value = userAnswers.value[currentQuestion.value.id]
      }
    }

    const previousQuestion = () => {
      if (currentQuestionIndex.value > 0) {
        currentQuestionIndex.value--
        selectedAnswer.value = userAnswers.value[currentQuestion.value.id]
      }
    }

    const submitQuiz = async () => {
      try {
        isSubmitting.value = true

        // Prepare answers array
        const answers = Object.keys(userAnswers.value).map(questionId => ({
          questionId: parseInt(questionId),
          selectedAnswerId: userAnswers.value[questionId]
        }))

        // Submit quiz
        const response = await apiService.submitQuiz(route.params.id, answers)

        if (response.success) {
          // Navigate to results page, include summary in query for display
          const { attemptId, score, totalQuestions, correctCount } = response.results
          router.push(`/quiz/${route.params.id}/results/${attemptId}?score=${score}&total=${totalQuestions}&correct=${correctCount}`)
        } else {
          error.value = response.message || 'Failed to submit quiz'
        }
      } catch (err) {
        error.value = err.response?.data?.message || err.message || 'Failed to submit quiz'
      } finally {
        isSubmitting.value = false
      }
    }

    onMounted(async () => {
      await checkAuth()
      await loadQuiz()
    })

    return {
      quiz,
      questions,
      loading,
      error,
      isLoggedIn,
      isSubmitting,
      currentQuestionIndex,
      selectedAnswer,
      currentQuestion,
      progressPercentage,
      selectAnswer,
      nextQuestion,
      previousQuestion,
      submitQuiz,
      showFeedback,
      isCorrect
    }
  }
}
</script>

<style scoped>
.quiz-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
}

.loading, .error, .login-required {
  text-align: center;
  padding: 3rem;
}

.loading h2, .error h2, .login-required h2 {
  color: #2c3e50;
  margin-bottom: 1rem;
}

.error {
  color: #e74c3c;
}

.login-required {
  color: #f39c12;
}

.quiz-header {
  text-align: center;
  margin-bottom: 2rem;
}

.quiz-header h1 {
  color: #2c3e50;
  margin-bottom: 0.5rem;
}

.quiz-header p {
  color: #7f8c8d;
  margin-bottom: 2rem;
}

.quiz-progress {
  display: flex;
  align-items: center;
  gap: 1rem;
  justify-content: center;
}

.progress-bar {
  width: 300px;
  height: 8px;
  background-color: #ecf0f1;
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background-color: #3498db;
  transition: width 0.3s ease;
}

.progress-text {
  font-weight: bold;
  color: #2c3e50;
}

.question-container {
  margin-bottom: 2rem;
}

.question-card {
  background: white;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.question-text {
  color: #2c3e50;
  margin-bottom: 2rem;
  font-size: 1.2rem;
  line-height: 1.5;
}

.answers-container {
  margin-bottom: 2rem;
}

.answer-option {
  display: flex;
  align-items: center;
  padding: 1rem;
  margin-bottom: 0.5rem;
  border: 2px solid #ecf0f1;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.answer-option:hover:not(.disabled) {
  border-color: #3498db;
  background-color: #f8f9fa;
}

.answer-option.selected {
  border-color: #3498db;
  background-color: #e3f2fd;
}

.answer-option.disabled {
  cursor: not-allowed;
  opacity: 0.6;
}

.answer-radio {
  margin-right: 1rem;
}

.radio-circle {
  width: 20px;
  height: 20px;
  border: 2px solid #bdc3c7;
  border-radius: 50%;
  transition: all 0.3s ease;
}

.radio-circle.checked {
  border-color: #3498db;
  background-color: #3498db;
  position: relative;
}

.radio-circle.checked::after {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 8px;
  height: 8px;
  background-color: white;
  border-radius: 50%;
}

.answer-text {
  flex: 1;
  color: #2c3e50;
  font-size: 1rem;
}

.quiz-navigation {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.btn {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
  transition: background-color 0.3s;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-primary {
  background-color: #3498db;
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background-color: #2980b9;
}

.btn-secondary {
  background-color: #95a5a6;
  color: white;
}

.btn-secondary:hover:not(:disabled) {
  background-color: #7f8c8d;
}

.btn-success {
  background-color: #27ae60;
  color: white;
}

.btn-success:hover:not(:disabled) {
  background-color: #229954;
}

.feedback-message {
  text-align: center;
  font-weight: bold;
  font-size: 1.2rem;
  margin-top: 1rem;
  padding: 0.75rem;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.feedback-message.correct {
  color: #27ae60;
  background-color: #eafaf1;
  border: 2px solid #27ae60;
  margin-bottom: 1rem;
}

.feedback-message.wrong {
  color: #e74c3c;
  background-color: #fdecea;
  border: 2px solid #e74c3c;
  margin-bottom: 1rem;
}

</style>
