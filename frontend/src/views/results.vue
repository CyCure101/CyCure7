<template>
  <div class="page">
    <h1>Mina resultat</h1>
    <p class="subtitle">Följ dina framsteg och se detaljerade testresultat.</p>

    <!-- Summary Statistics Grid -->
    <div class="summary-grid">
      <!-- Current Level Card -->
      <div class="card summary-card">
        <div class="card-header">
          <h4>Nuvarande nivå</h4>
          <span class="icon-trophy">🏆</span>
        </div>
        <p class="main-stat">{{ currentLevel }}</p>
        <div class="stat-detail">
          <span class="detail-value">{{ currentPoints }} poäng</span>
          <div class="progress-bar-container">
            <div class="progress-bar" :style="{ width: (currentPoints / goalPoints) * 100 + '%' }"></div>
          </div>
          <span class="detail-goal">{{ goalPoints }} poäng</span>
        </div>
      </div>

      <!-- Completed Tests Card -->
      <div class="card summary-card">
        <div class="card-header">
          <h4>Genomförda tester</h4>
          <span class="icon-completed">🎯</span>
        </div>
        <p class="main-stat">{{ completedTests }} / {{ totalTests }}</p>
        <p class="sub-stat">{{ completionPercentage }}% genomfört</p>
      </div>

      <!-- Average Score Card -->
      <div class="card summary-card">
        <div class="card-header">
          <h4>Genomsnittlig poäng</h4>
          <span class="icon-score">🏅</span>
        </div>
        <p class="main-stat">{{ averageScore }}%</p>
        <p class="sub-stat">Över alla genomförda tester</p>
      </div>

      <!-- Study Time Card -->
      <div class="card summary-card">
        <div class="card-header">
          <h4>Studietid</h4>
          <span class="icon-time">🕒</span>
        </div>
        <p class="main-stat">{{ totalStudyTime }}h {{ totalStudyMinutes }}m</p>
        <p class="sub-stat">{{ completedModules }} moduler genomförda</p>
      </div>
    </div>

    <!-- Test History Section -->
    <h2 class="section-title">Testhistorik</h2>

    <div class="test-history-container card">
      <!-- Placeholder when no tests are completed -->
      <div v-if="testHistory.length === 0" class="empty-state">
        <span class="trophy-icon">🏆</span>
        <h3>Inga tester genomförda än</h3>
        <p>Börja med ditt första quiz för att se dina resultat här.</p>
        <button class="action-btn btn-go-quiz" @click="goToQuiz">Gå till Quiz</button>
      </div>

      <!-- List of completed tests (Hidden while testHistory.length === 0) -->
      <div v-else class="test-list">
        <!-- Loop through test results here if data were available -->
        <div v-for="test in testHistory" :key="test.id" class="test-item">
          <div class="test-info">
            <span class="test-title">{{ test.title }}</span>
            <span class="test-date">{{ test.date }}</span>
          </div>
          <div class="test-result">
            <span :class="['result-badge', test.score > 70 ? 'badge-pass' : 'badge-fail']">{{ test.score }}%</span>
            <span class="arrow-icon">❯</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Achievements/Prestastioner Section -->
    <h2 class="section-title">Prestationer</h2>
    <div class="achievements-container card">
      <p class="empty-state-text">Dina prestationer visas här när du låser upp dem!</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();

// Mock Data for the Summary Cards
const currentPoints = ref(150);
const goalPoints = ref(400); // Points required for the next level (e.g., Analyst)
const completedTests = ref(0);
const totalTests = ref(6);
const averageScore = ref(0);
const completedModules = ref(0);
const totalStudyTime = ref(0); // hours
const totalStudyMinutes = ref(0); // minutes

// Mock Data for Test History
// NOTE: This array is currently empty to show the "empty state" UI
const testHistory = ref([]);
/* Example data if tests were completed:
const testHistory = ref([
  { id: 1, title: 'Grundläggande Cybersäkerhet Test', score: 85, date: '2025-10-01' },
  { id: 2, title: 'Lösenordssäkerhet Quiz', score: 65, date: '2025-09-28' }
]);
*/

// Computed Properties
const currentLevel = computed(() => (currentPoints.value < 200 ? 'Rookie' : 'Analyst'));

const completionPercentage = computed(() => {
  return totalTests.value > 0 ? Math.round((completedTests.value / totalTests.value) * 100) : 0;
});

// Methods
const goToQuiz = () => {
  router.push('/quiz');
};
</script>

<style scoped>
.page {
  padding: 20px;
  background-color: #f4f7f9;
}

h1 {
  color: #333;
  margin-bottom: 0.5rem;
}

.subtitle {
  color: #666;
  font-size: 1rem;
  margin-bottom: 25px;
}

.section-title {
  color: #333;
  margin-top: 30px;
  margin-bottom: 20px;
  border-bottom: 2px solid #e0e0e0;
  padding-bottom: 5px;
}

.card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  transition: transform 0.2s;
}

.card:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.1);
}

/* --- SUMMARY GRID LAYOUT (Top 4 Cards) --- */
.summary-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
}

.summary-card {
  display: flex;
  flex-direction: column;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.summary-card h4 {
  color: #555;
  font-weight: normal;
  margin: 0;
  font-size: 1rem;
}

.icon-trophy, .icon-completed, .icon-score, .icon-time {
  font-size: 1.5rem;
  opacity: 0.7;
}

.main-stat {
  font-size: 2rem;
  font-weight: bold;
  color: #007bff;
  margin: 0;
  line-height: 1.2;
}

.sub-stat {
  color: #888;
  font-size: 0.9rem;
  margin-top: 5px;
}

.stat-detail {
  margin-top: 15px;
}

.detail-value, .detail-goal {
  font-size: 0.9rem;
  color: #555;
  font-weight: 500;
}

.progress-bar-container {
  height: 6px;
  background-color: #e0eeef;
  border-radius: 3px;
  margin: 8px 0;
  overflow: hidden;
}

.progress-bar {
  height: 100%;
  background-color: #42b883; /* Use a success color */
  transition: width 0.5s;
}

/* --- TEST HISTORY --- */
.test-history-container {
  min-height: 250px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.empty-state {
  text-align: center;
  padding: 40px 20px;
}

.trophy-icon {
  font-size: 3rem;
  display: block;
  margin-bottom: 10px;
}

.empty-state h3 {
  color: #333;
  margin: 10px 0 5px 0;
}

.empty-state p {
  color: #888;
  margin-bottom: 20px;
}

.action-btn {
  padding: 10px 20px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-weight: bold;
  transition: background-color 0.2s, transform 0.1s;
}

.btn-go-quiz {
  background-color: #007bff;
  color: white;
  box-shadow: 0 2px 4px rgba(0, 123, 255, 0.3);
}

.btn-go-quiz:hover {
  background-color: #0056b3;
  transform: translateY(-1px);
}

/* --- ACHIEVEMENTS --- */
.achievements-container {
  min-height: 100px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.empty-state-text {
  color: #888;
  font-style: italic;
}
</style>
