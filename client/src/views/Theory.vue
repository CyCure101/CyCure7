<template>
  <div class="theory-page">
    <div class="theory-card">
      <!-- Progress Bar -->
      <div class="progress-container">
        <div class="progress-bar" :style="{ width: progressPercent + '%' }"></div>
      </div>
      <p class="progress-text">{{ currentSection + 1 }} / {{ totalSections }} completed</p>

      <h1>{{ theory.title }}</h1>
      <p class="description">{{ theory.description }}</p>

      <!-- Video Section (if available) -->
      <div v-if="theory.videoUrl && currentSection === 0" class="video-section">
        <h3>📹 Watch Introduction Video</h3>
        <div class="video-wrapper">
          <iframe
              :src="theory.videoUrl"
              frameborder="0"
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
              allowfullscreen
              @load="markVideoWatched"
          ></iframe>
        </div>
        <label class="checkbox-label">
          <input type="checkbox" v-model="videoWatched"/>
          I have watched the video
        </label>
      </div>

      <!-- Content Sections with Flip Cards -->
      <div class="sections-container">
        <div
            v-show="currentSection === idx"
            v-for="(section, idx) in theory.sections"
            :key="idx"
            class="content-section"
        >
          <h2>{{ section.heading }}</h2>

          <!-- Flip Cards -->
          <div class="flip-cards-grid">
            <div
                v-for="(point, i) in section.points"
                :key="i"
                class="flip-card"
                :class="{ flipped: flippedCards[currentSection]?.[i] }"
                @click="flipCard(currentSection, i)"
            >
              <div class="flip-card-inner">
                <div class="flip-card-front">
                  <div class="card-icon">💡</div>
                  <p>Click to reveal tip {{ i + 1 }}</p>
                </div>
                <div class="flip-card-back">
                  <p>{{ point }}</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Mini Quiz Question -->
          <div v-if="section.quiz" class="mini-quiz">
            <h4>✅ Quick Check</h4>
            <p class="quiz-question">{{ section.quiz.question }}</p>
            <div class="quiz-options">
              <button
                  v-for="(option, i) in section.quiz.options"
                  :key="i"
                  @click="answerQuiz(currentSection, i)"
                  :class="{
                  'selected': quizAnswers[currentSection] === i,
                  'correct': quizAnswers[currentSection] === i && i === section.quiz.correct,
                  'incorrect': quizAnswers[currentSection] === i && i !== section.quiz.correct
                }"
              >
                {{ option }}
              </button>
            </div>
            <p v-if="quizAnswers[currentSection] === section.quiz.correct" class="feedback success">
              ✅ Correct! {{ section.quiz.feedback }}
            </p>
            <p v-else-if="quizAnswers[currentSection] !== null && quizAnswers[currentSection] !== undefined"
               class="feedback error">
              ❌ Not quite. Try another answer!
            </p>
          </div>
        </div>
      </div>

      <!-- Navigation -->
      <div class="navigation-buttons">
        <button
            @click="previousSection"
            :disabled="currentSection === 0"
            class="btn-nav"
        >
          ← Previous
        </button>
        <button
            v-if="currentSection < totalSections - 1"
            @click="nextSection"
            :disabled="!canProceed"
            class="btn-nav btn-next"
        >
          Next →
        </button>
        <button
            v-else
            @click="completeTheory"
            :disabled="!allSectionsCompleted"
            class="btn-complete"
        >
          ✅ Complete Theory
        </button>
      </div>

      <!-- Tip Box -->
      <div class="tip-box">
        <h4>💡 Pro Tip</h4>
        <p>{{ theory.tip }}</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import {ref, computed, onMounted, reactive} from 'vue'
import {useRoute, useRouter} from 'vue-router'
import apiService from '../services/apiService'
import {currentUser} from '../../auth'

const route = useRoute()
const router = useRouter()

const theory = ref({})
const currentSection = ref(0)
const flippedCards = reactive({})
const quizAnswers = reactive({})
const videoWatched = ref(false)

const allTheory = {
  1: {
    title: 'Phishing Awareness',
    description: 'Learn how to identify and avoid phishing attempts.',
    videoUrl: 'https://www.youtube.com/embed/6EmD3k3Pb8Y',
    sections: [
      {
        heading: 'What is Phishing?',
        points: [
          'Phishing is a cyberattack where criminals trick you into revealing sensitive information',
          'Attackers often impersonate trusted organizations like banks or delivery companies',
          'Common methods include fake emails, text messages, and fraudulent websites'
        ],
        quiz: {
          question: 'What is the main goal of a phishing attack?',
          options: [
            'To steal sensitive information',
            'To improve email security',
            'To update your software',
            'To verify your identity'
          ],
          correct: 0,
          feedback: 'Phishing attacks aim to steal credentials, financial data, or personal information.'
        }
      },
      {
        heading: '🔍 How to Recognize Phishing',
        points: [
          'Check for spelling mistakes and poor grammar in messages',
          'Examine the sender\'s email address carefully - it may look similar but slightly different',
          'Be suspicious of urgent requests asking for login credentials or payment details',
          'Hover over links to see the actual URL before clicking'
        ],
        quiz: {
          question: 'Which of these is a red flag for phishing?',
          options: [
            'Email from your actual bank manager',
            'Urgent request for password reset from unknown sender',
            'Regular company newsletter',
            'Appointment confirmation you booked'
          ],
          correct: 1,
          feedback: 'Urgent requests from unknown sources are classic phishing tactics!'
        }
      },
      {
        heading: '🛡️ Protection Strategies',
        points: [
          'Never click suspicious links or download attachments from unknown sources',
          'Always verify requests through official channels (call the company directly)',
          'Use email filters and anti-phishing tools',
          'Report suspected phishing attempts to your IT department'
        ],
        quiz: {
          question: 'What should you do if you receive a suspicious email?',
          options: [
            'Click the link to verify it\'s real',
            'Reply asking if it\'s legitimate',
            'Report it and verify through official channels',
            'Forward it to all your contacts'
          ],
          correct: 2,
          feedback: 'Always verify through official channels and report suspicious activity!'
        }
      }
    ],
    tip: 'If it looks too urgent or too good to be true — it probably is. Take a moment to verify!'
  },
  2: {
    title: 'Password Security',
    description: 'Master the art of creating and managing secure passwords.',
    videoUrl: 'https://www.youtube.com/embed/TvrFpAFitQ0',
    sections: [
      {
        heading: '🔐 Why Strong Passwords Matter',
        points: [
          'Weak passwords are the easiest entry point for hackers',
          'Automated tools can crack simple passwords in seconds',
          'A strong password is your first line of defense'
        ],
        quiz: {
          question: 'Which password is strongest?',
          options: [
            'password123',
            'MyName2024',
            'Tr0ub4dor&3',
            'correcthorsebatterystaple'
          ],
          correct: 3,
          feedback: 'Long passphrases with random words are both secure and memorable!'
        }
      },
      {
        heading: '✨ Creating Secure Passwords',
        points: [
          'Use at least 12 characters with a mix of letters, numbers, and symbols',
          'Avoid personal information like names, birthdays, or pet names',
          'Never reuse passwords across multiple accounts',
          'Consider using memorable passphrases instead of complex gibberish'
        ],
        quiz: {
          question: 'What makes a password weak?',
          options: [
            'Using 16 random characters',
            'Using your birthday',
            'Using a password manager',
            'Enabling 2FA'
          ],
          correct: 1,
          feedback: 'Personal information is easy for attackers to guess or find on social media!'
        }
      },
      {
        heading: '🔧 Password Management',
        points: [
          'Use a password manager to generate and store complex passwords securely',
          'Enable two-factor authentication (2FA) for an extra layer of security',
          'Change passwords immediately if you suspect a breach',
          'Never share passwords via email or text'
        ],
        quiz: {
          question: 'What is the best way to remember many complex passwords?',
          options: [
            'Write them on sticky notes',
            'Use the same password everywhere',
            'Use a password manager',
            'Use simple passwords'
          ],
          correct: 2,
          feedback: 'Password managers securely store and generate unique passwords for each account!'
        }
      }
    ],
    tip: 'Your password is like your toothbrush — never share it, and change it regularly!'
  },
  3: {
    title: 'Social Engineering',
    description: 'Understand manipulation tactics and how to defend against them.',
    videoUrl: 'https://www.youtube.com/embed/Wk2yk3XQKAQ',
    sections: [
      {
        heading: '🎭 What is Social Engineering?',
        points: [
          'Social engineering manipulates people into revealing confidential information',
          'It exploits human psychology rather than technical vulnerabilities',
          'Attackers build trust or create urgency to bypass security measures'
        ],
        quiz: {
          question: 'Social engineering primarily targets:',
          options: [
            'Computer systems',
            'Network firewalls',
            'Human behavior',
            'Operating systems'
          ],
          correct: 2,
          feedback: 'Social engineering exploits human trust and emotions, not technical systems!'
        }
      },
      {
        heading: '🎯 Common Tactics',

        points: [
          'Pretexting: Attacker creates a fabricated scenario to obtain information',
          'Baiting: Offering something attractive (free software) to spread malware',
          'Tailgating: Following authorized person into restricted areas',
          'Quid pro quo: Offering a service in exchange for information'
        ],
        quiz: {
          question: 'An attacker calls pretending to be IT support asking for your password. This is:',
          options: [
            'Normal IT procedure',
            'Pretexting',
            'Tailgating',
            'Baiting'
          ],
          correct: 1,
          feedback: 'This is pretexting - creating a false scenario to steal information. Real IT never asks for passwords!'
        }
      },
      {
        heading: '🛡️ Defense Strategies',
        videoUrl: 'https://www.youtube.com/embed/Cmu73oxr-lE',
        points: [
          'Always verify the identity of anyone requesting sensitive information',
          'Be skeptical of urgent or emotional requests',
          'Follow established security protocols even under pressure',
          'Report suspicious behavior to security personnel'
        ],
        quiz: {
          question: 'How should you respond to urgent requests for sensitive data?',
          options: [
            'Comply immediately to avoid trouble',
            'Ignore them completely',
            'Verify through official channels first',
            'Share the data but ask for confirmation later'
          ],
          correct: 2,
          feedback: 'Always verify through official channels - urgency is a common manipulation tactic!'
        }
      }
    ],
    tip: 'When in doubt, verify! Legitimate requests can wait for proper authentication.'
  }
}

const totalSections = computed(() => theory.value.sections?.length || 0)

const progressPercent = computed(() => {
  if (totalSections.value === 0) return 0
  return ((currentSection.value + 1) / totalSections.value) * 100
})

const canProceed = computed(() => {
  const section = theory.value.sections?.[currentSection.value]
  if (!section) return false

  // Check if video needs to be watched (only on first section)
  if (currentSection.value === 0 && theory.value.videoUrl && !videoWatched.value) {
    return false
  }

  // Check if all cards are flipped
  const allCardsFlipped = section.points.every((_, i) => flippedCards[currentSection.value]?.[i])

  // Check if quiz is answered correctly
  const quizAnswered = !section.quiz || quizAnswers[currentSection.value] === section.quiz.correct

  return allCardsFlipped && quizAnswered
})

const allSectionsCompleted = computed(() => {
  return theory.value.sections?.every((section, index) => {
    const allCardsFlipped = section.points.every((_, i) => flippedCards[index]?.[i])
    const quizAnswered = !section.quiz || quizAnswers[index] === section.quiz.correct
    return allCardsFlipped && quizAnswered
  }) && (!theory.value.videoUrl || videoWatched.value)
})

onMounted(() => {
  const quizId = route.params.id
  theory.value = allTheory[quizId] || {
    title: 'Theory Not Found',
    description: 'This learning module is not available yet.',
    sections: [],
    tip: ''
  }
})

const flipCard = (sectionIndex, cardIndex) => {
  if (!flippedCards[sectionIndex]) {
    flippedCards[sectionIndex] = {}
  }
  flippedCards[sectionIndex][cardIndex] = true
}

const answerQuiz = (sectionIndex, answerIndex) => {
  quizAnswers[sectionIndex] = answerIndex
}

const markVideoWatched = () => {
  setTimeout(() => {
    videoWatched.value = true
  }, 35000)
}

const nextSection = () => {
  if (canProceed.value && currentSection.value < totalSections.value - 1) {
    currentSection.value++
  }
}

const previousSection = () => {
  if (currentSection.value > 0) {
    currentSection.value--
  }
}

const completeTheory = async () => {
  if (!allSectionsCompleted.value) {
    alert('Please complete all sections before finishing!')
    return
  }

  const quizId = route.params.id
  console.log('Completing theory for quizId:', quizId, 'Type:', typeof quizId)

  try {
    const userId = currentUser.value?.id
    console.log('Current user:', currentUser.value)
    console.log('UserId:', userId)

    if (!userId) {
      alert('You must be logged in to save progress.')
      await router.push('/login')
      return
    }

    console.log('Calling saveUserProgress with userId:', userId, 'quizId:', quizId)
    const response = await apiService.saveUserProgress(userId, quizId)
    console.log('Response:', response)

    if (response.success) {
      alert('🎉 Theory completed! You can now start the quiz.')
      await router.push('/')
    } else {
      alert('❌ Failed to save: ' + (response.message || 'Unknown error'))
    }
  } catch (error) {
    console.error('Network error:', error)
    console.error('Error response:', error.response?.data)
    const errorMessage = error.response?.data?.message || error.response?.data?.error || error.message || 'Unknown error'
    alert('❌ Network error: ' + errorMessage)
  }
}
</script>

<style scoped>
.theory-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #0d1117 0%, #161b22 100%);
  color: #e6edf3;
  padding: 2rem;
  display: flex;
  justify-content: center;
  align-items: center;
}

.theory-card {
  background: #161b22;
  border-radius: 16px;
  padding: 2rem;
  max-width: 900px;
  width: 100%;
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.4);
  border: 1px solid #30363d;
}

.progress-container {
  background: #30363d;
  border-radius: 10px;
  height: 10px;
  margin-bottom: 0.5rem;
  overflow: hidden;
}

.progress-bar {
  background: linear-gradient(90deg, #00ff88, #00c2ff);
  height: 100%;
  transition: width 0.5s ease;
}

.progress-text {
  text-align: center;
  color: #9ba1a6;
  font-size: 0.9rem;
  margin-bottom: 1rem;
}

h1 {
  color: #00ff88;
  margin-bottom: 0.5rem;
  font-size: 2rem;
}

.description {
  color: #9ba1a6;
  font-style: italic;
  margin-bottom: 2rem;
}

.video-section {
  margin: 2rem 0;
  padding: 1.5rem;
  background: #0d1117;
  border-radius: 12px;
  border: 1px solid #30363d;
}

.video-wrapper {
  position: relative;
  padding-bottom: 56.25%;
  height: 0;
  overflow: hidden;
  border-radius: 8px;
  margin: 1rem 0;
}

.video-wrapper iframe {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}

.flip-cards-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}

.flip-card {
  perspective: 1000px;
  height: 180px;
  cursor: pointer;
}

.flip-card-inner {
  position: relative;
  width: 100%;
  height: 100%;
  transition: transform 0.6s;
  transform-style: preserve-3d;
}

.flip-card.flipped .flip-card-inner {
  transform: rotateY(180deg);
}

.flip-card-front,
.flip-card-back {
  position: absolute;
  width: 100%;
  height: 100%;
  backface-visibility: hidden;
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 1rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

.flip-card-front {
  background: linear-gradient(135deg, #00ff88, #00c2ff);
  color: #0d1117;
  font-weight: 600;
}

.flip-card-back {
  background: #161b22;
  border: 1px solid #00ff88;
  transform: rotateY(180deg);
  color: #e6edf3;
  text-align: center;
}

.mini-quiz {
  background: #0d1117;
  padding: 1.5rem;
  border-radius: 12px;
  border: 1px solid #30363d;
  margin-top: 2rem;
}

.quiz-question {
  font-weight: 600;
  color: #e6edf3;
  margin: 1rem 0;
}

.quiz-options {
  display: grid;
  gap: 0.75rem;
}

.quiz-options button {
  padding: 0.75rem 1rem;
  border: 2px solid #30363d;
  background: #161b22;
  color: #e6edf3;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
  text-align: left;
}

.quiz-options button:hover {
  border-color: #00c2ff;
  background: #1c222c;
  transform: translateY(-2px);
}

.quiz-options button.selected {
  border-color: #00ff88;
  background: rgba(0, 255, 136, 0.1);
}

.quiz-options button.correct {
  background: rgba(0, 255, 136, 0.2);
  border-color: #00ff88;
}

.quiz-options button.incorrect {
  background: rgba(229, 62, 62, 0.2);
  border-color: #e53e3e;
}

.feedback {
  margin-top: 1rem;
  padding: 0.75rem;
  border-radius: 8px;
  font-weight: 500;
}

.feedback.success {
  background: rgba(0, 255, 136, 0.1);
  color: #00ff88;
}

.feedback.error {
  background: rgba(229, 62, 62, 0.1);
  color: #e53e3e;
}

.navigation-buttons {
  display: flex;
  gap: 1rem;
  margin: 2rem 0;
  justify-content: space-between;
}

.btn-nav {
  padding: 0.75rem 1.5rem;
  border: 2px solid #00c2ff;
  background: transparent;
  color: #00c2ff;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.2s;
}

.btn-nav:hover:not(:disabled) {
  background: #00c2ff;
  color: #0d1117;
}

.btn-complete {
  background: linear-gradient(135deg, #00ff88, #00c2ff);
  color: #0d1117;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 700;
  transition: all 0.2s;
}

.btn-complete:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 255, 136, 0.3);
}

.tip-box {
  background: rgba(0, 194, 255, 0.1);
  padding: 1.5rem;
  border-radius: 12px;
  border-left: 4px solid #00c2ff;
}

.tip-box h4 {
  margin-bottom: 0.5rem;
  color: #00c2ff;
}

.tip-box p {
  color: #9ba1a6;
}

@media (max-width: 768px) {
  .flip-cards-grid {
    grid-template-columns: 1fr;
  }

  .navigation-buttons {
    flex-direction: column;
  }
}
</style>
