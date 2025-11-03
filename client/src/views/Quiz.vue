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
          <!-- NEW: Segmented Progress Bar based on question results -->
          <div class="segmented-progress-bar">
            <div
                v-for="(question, index) in questions"
                :key="question.id"
                class="progress-segment"
                :class="{
                    'segment-correct': questionResults[question.id] === 'correct',
                    'segment-wrong': questionResults[question.id] === 'wrong',
                    'segment-current': index === currentQuestionIndex
                }"
            ></div>
          </div>
          <!-- End NEW Segmented Progress Bar -->

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
                :class="getAnswerClasses(answer.id)"
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

          <div v-if="showFeedback && !isCorrect" class="correct-answer-hint">
            <p>Rätt svar var: <strong>{{ correctAnswerText }}</strong></p>
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
                :disabled="isSubmitting"
            >
              Next
            </button>

            <button
                v-else
                @click="submitQuiz"
                class="btn btn-success"
                :disabled="isSubmitting"
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
import {ref, computed, onMounted} from 'vue'
import {useRoute, useRouter} from 'vue-router'
import apiService from '../services/apiService'
import {currentUser} from '../../auth'

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

    const currentQuestionIndex = ref(0)
    const selectedAnswer = ref(null)
    const userAnswers = ref({}) // Store all user answers (questionId: selectedAnswerId)
    const questionResults = ref({}) // Store feedback for each question (questionId: 'correct'/'wrong')

    const currentQuestion = computed(() => {
      return questions.value[currentQuestionIndex.value] || {}
    })

    // Beräknar feedback för den aktuella frågan baserat på sparad data
    const currentQuestionResult = computed(() => {
      const questionId = currentQuestion.value.id;
      // Returnerar 'correct', 'wrong', eller null
      return questionResults.value[questionId] || null;
    })

    // Styr om feedback-meddelandet ska visas
    const showFeedback = computed(() => {
      // Visa feedback om frågan har ett sparat resultat
      return !!currentQuestionResult.value;
    })

    // Styr om feedback-meddelandet ska vara grönt eller rött
    const isCorrect = computed(() => {
      return currentQuestionResult.value === 'correct';
    })

    // NY: Visar rätt svarstext när användaren har svarat fel
    const correctAnswerText = computed(() => {
      const correct = currentQuestion.value.answers.find(a => a.is_correct === 1 || a.is_correct === true);
      return correct ? correct.answer_text : 'N/A';
    });

    // NY: Beräknar dynamiska CSS-klasser för varje svarsalternativ
    const getAnswerClasses = (answerId) => {
      const classes = {};
      const questionId = currentQuestion.value.id;
      const isAnswered = !!questionResults.value[questionId];
      const isSelected = selectedAnswer.value === answerId;

      classes.disabled = isSubmitting.value || isAnswered;

      if (isAnswered) {
        const isCorrectAnswer = currentQuestion.value.answers.find(a => a.id === answerId)?.is_correct;

        if (isSelected) {
          // Detta är det valda svaret, sätt färg baserat på korrekthet
          classes['selected-correct'] = isCorrect.value;
          classes['selected-wrong'] = !isCorrect.value;

        } else if (!isCorrect.value && isCorrectAnswer) {
          // Om fel svar valdes (isCorrect.value är false), markera det RÄTTA svaret också (blå kant)
          classes['correct-hint'] = true;
        }

      } else {
        // Före svar: Markera endast om det är valt
        classes.selected = isSelected;
      }

      return classes;
    };


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

        // Initialize user answers and results
        questions.value.forEach((question) => {
          userAnswers.value[question.id] = null
          questionResults.value[question.id] = null // Initialize results storage
        })

      } catch (err) {
        error.value = err.response?.data?.message || err.message || 'Failed to load quiz'
      } finally {
        loading.value = false
      }
    }

    const selectAnswer = (answerId) => {
      // Låser valet om frågan redan är besvarad (dvs. om det finns ett sparat svar)
      if (isSubmitting.value || userAnswers.value[currentQuestion.value.id]) return

      selectedAnswer.value = answerId
      userAnswers.value[currentQuestion.value.id] = answerId

      // Find the selected answer object
      const answer = currentQuestion.value.answers.find(a => a.id === answerId)

      // Check if correct
      const isAnswerCorrect = answer.is_correct === 1 || answer.is_correct === true

      // SPARA feedback-resultatet i questionResults (detta triggar den nya färglogiken i progressbaren)
      questionResults.value[currentQuestion.value.id] = isAnswerCorrect ? 'correct' : 'wrong'

      // showFeedback och isCorrect uppdateras nu automatiskt via computed properties
    }

    const nextQuestion = () => {
      if (currentQuestionIndex.value < questions.value.length - 1) {
        currentQuestionIndex.value++
        // Ladda det sparade svaret för den nya frågan
        selectedAnswer.value = userAnswers.value[currentQuestion.value.id]
      }
    }

    const previousQuestion = () => {
      if (currentQuestionIndex.value > 0) {
        currentQuestionIndex.value--
        // Ladda det sparade svaret för den nya frågan
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
          const {attemptId, score, totalQuestions, correctCount} = response.results
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
      userAnswers,
      questionResults,
      currentQuestion,
      selectAnswer,
      nextQuestion,
      previousQuestion,
      submitQuiz,
      showFeedback,
      isCorrect,
      correctAnswerText, // Exponera för att visa hint
      getAnswerClasses // Exponera den nya funktionen
    }
  }
}
</script>

<style scoped>
.quiz-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
  color: #e6edf3;
  background: linear-gradient(135deg, #0d1117 0%, #161b22 100%);
  min-height: 100vh;
}

.loading, .error, .login-required {
  text-align: center;
  padding: 3rem;
}

.loading h2, .error h2, .login-required h2 {
  color: #e6edf3;
  margin-bottom: 1rem;
}

.error {
  color: #e53e3e;
}

.login-required {
  color: #fbbf24;
}

.quiz-header {
  text-align: center;
  margin-bottom: 2rem;
}

.quiz-header h1 {
  color: #00ff88;
  margin-bottom: 0.5rem;
  font-size: 2rem;
}

.quiz-header p {
  color: #9ba1a6;
  margin-bottom: 2rem;
}

.quiz-progress {
  display: flex;
  align-items: center;
  gap: 1rem;
  justify-content: center;
}

/* NEW: Styles for Segmented Progress Bar */
.segmented-progress-bar {
  display: flex;
  width: 300px;
  height: 8px;
  background-color: #30363d; /* Default background for unanswered/empty */
  border-radius: 4px;
  overflow: hidden;
  gap: 2px; /* Small gap between segments for visual clarity */
}

.progress-segment {
  flex-grow: 1; /* Makes all segments take equal width */
  height: 100%;
  background-color: #30363d; /* Default/Unanswered color */
  transition: background-color 0.3s ease, box-shadow 0.3s ease;
  border-radius: 2px; /* Slight rounding for each segment */
}

.progress-segment.segment-correct {
  background-color: #00ff88; /* Green for Correct */
}

.progress-segment.segment-wrong {
  background-color: #e53e3e; /* Red for Wrong */
}

.progress-segment.segment-current {
  /* Blue highlight for the currently viewed question */
  background-color: #00c2ff;
  box-shadow: 0 0 5px rgba(0, 194, 255, 0.8);
}
/* END NEW Styles for Segmented Progress Bar */

/* The old .progress-bar and .progress-fill styles are removed */

.progress-text {
  font-weight: bold;
  color: #9ba1a6;
}

.question-container {
  margin-bottom: 2rem;
}

.question-card {
  background: #161b22;
  padding: 2rem;
  border-radius: 12px;
  border: 1px solid #30363d;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.3);
}

.question-text {
  color: #e6edf3;
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
  margin-bottom: 0.75rem;
  border: 2px solid #30363d;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  background: #0d1117;
}

.answer-option:hover:not(.disabled) {
  border-color: #00c2ff;
  background-color: rgba(0, 194, 255, 0.05);
  transform: translateY(-2px);
}

/* 1. Klass för valt alternativ FÖRE bedömning */
.answer-option.selected {
  border-color: #00ff88; /* Grön kant som tidigare vid val */
  background: rgba(0, 255, 136, 0.08);
}

/* 2. Klass för RÄTT svar EFTER bedömning (om det är valt) */
.answer-option.selected-correct {
  border-color: #00ff88;
  background: rgba(0, 255, 136, 0.15); /* Tydligare grön bakgrund */
  cursor: default;
}

/* 3. Klass för FEL svar EFTER bedömning (om det är valt) */
.answer-option.selected-wrong {
  border-color: #e53e3e; /* Röd kant */
  background: rgba(229, 62, 62, 0.15); /* Tydligare röd bakgrund */
  cursor: default;
}

/* 4. Klass för att visa HINT (det rätta svaret) när ett fel svar valdes */
.answer-option.correct-hint {
  border-color: #7cfd39; /* Blå kant */
  background: rgba(0, 194, 255, 0.08);
  cursor: default;
}


/* Added logic to disable answer options if already answered */
.answer-option.disabled {
  cursor: not-allowed;
  opacity: 0.6; /* Slight reduction in opacity */
}

.answer-radio {
  margin-right: 1rem;
}

.radio-circle {
  width: 20px;
  height: 20px;
  border: 2px solid #9ba1a6;
  border-radius: 50%;
  transition: all 0.3s ease;
}

/* Uppdatera radio-cirkeln för att matcha färgerna */
.answer-option.selected-correct .radio-circle.checked {
  border-color: #00ff88;
  background: #00ff88;
}

.answer-option.selected-wrong .radio-circle.checked {
  border-color: #e53e3e;
  background: #e53e3e;
}

.answer-option.selected .radio-circle.checked {
  border-color: #00ff88;
  background: #00ff88;
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
  background-color: #0d1117;
  border-radius: 50%;
}

.answer-text {
  flex: 1;
  color: #e6edf3;
  font-size: 1rem;
}

.quiz-navigation {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.btn {
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 600;
  transition: all 0.3s ease;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-primary {
  background: linear-gradient(135deg, #00ff88, #00c2ff);
  color: #0d1117;
  border: none;
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 10px rgba(0, 255, 136, 0.4);
}

.btn-secondary {
  background: transparent;
  border: 2px solid #00c2ff;
  color: #00c2ff;
}

.btn-secondary:hover:not(:disabled) {
  background: #00c2ff;
  color: #0d1117;
}

.btn-success {
  background: #00ff88;
  color: #0d1117;
  border: none;
}

.btn-success:hover:not(:disabled) {
  background: #00c2ff;
  color: #0d1117;
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
  color: #00ff88;
  background-color: rgba(0, 255, 136, 0.1);
  border: 2px solid #00ff88;
  margin-bottom: 1rem;
}

.feedback-message.wrong {
  color: #e53e3e;
  background-color: rgba(229, 62, 62, 0.1);
  border: 2px solid #e53e3e;
  margin-bottom: 1rem;
}

/* NY: Visar rätt svar när man svarat fel */
.correct-answer-hint {
  text-align: center;
  font-size: 1rem;
  padding: 0.5rem;
  margin-bottom: 1rem;
  border-radius: 8px;
  background-color: rgba(0, 194, 255, 0.1);
  color: #318d02;
  border: 1px solid #266c01;
}
</style>
