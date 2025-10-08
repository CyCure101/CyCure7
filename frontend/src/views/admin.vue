<template>
  <div class="page">
    <h1>Administratörspanel</h1>
    <p class="subtitle">Hantera anställda, skapa tester och följ upp resultat.</p>

    <!-- Navigation Tabs Admin Page -->
    <div class="admin-tabs">
      <button :class="['tab-button', { 'active': currentTab === 'overview' }]" @click="currentTab = 'overview'">Översikt</button>
      <button :class="['tab-button', { 'active': currentTab === 'employees' }]" @click="currentTab = 'employees'">Anställda</button>
      <button :class="['tab-button', { 'active': currentTab === 'results' }]" @click="currentTab = 'results'">Resultat</button>
    </div>

    <!-- Overview Tab Content (No change) -->
    <div v-if="currentTab === 'overview'">
      <!-- Summary Grid (Top 4 Cards) -->
      <div class="summary-grid">
        <div class="card summary-card">
          <div class="card-header">
            <h4>Totalt anställda</h4>
            <span class="icon-employees">👥</span>
          </div>
          <p class="main-stat">{{ totalEmployees }}</p>
          <p class="sub-stat">+{{ newEmployeesThisMonth }} denna månad</p>
        </div>
        <div class="card summary-card">
          <div class="card-header">
            <h4>Aktiva utbildningar</h4>
            <span class="icon-active">📘</span>
          </div>
          <p class="main-stat">{{ activeTrainings }}</p>
          <p class="sub-stat">{{ newTrainingsThisWeek }} nya denna vecka</p>
        </div>
        <div class="card summary-card">
          <div class="card-header">
            <h4>Genomsnittlig poäng</h4>
            <span class="icon-score">🏆</span>
          </div>
          <p class="main-stat">{{ averageScore }}%</p>
          <p class="sub-stat">{{ scoreChange > 0 ? `+${scoreChange}%` : `${scoreChange}%` }} från förra månaden</p>
        </div>
        <div class="card summary-card alert-card">
          <div class="card-header">
            <h4>Behöver uppföljning</h4>
            <span class="icon-alert">⚠️</span>
          </div>
          <p class="main-stat">{{ needFollowUp }}</p>
          <p class="sub-stat">Anställda under 60%</p>
        </div>
      </div>

      <!-- Detailed Overview Grid (2 columns) -->
      <div class="overview-details-grid">
        <div class="card activity-card">
          <h2 class="section-title">🕒 Senaste aktivitet</h2>
          <div class="activity-list">
            <div v-for="activity in latestActivity" :key="activity.id" class="activity-item">
              <div class="activity-info">
                <p class="activity-name">{{ activity.name }}</p>
                <p class="activity-details">{{ activity.action }}</p>
                <p class="activity-time">{{ activity.time }}</p>
              </div>
              <div v-if="activity.score !== undefined"
                   :class="['activity-score', activity.score < 60 ? 'score-low' : 'score-high']">
                {{ activity.score }}%
              </div>
            </div>
          </div>
        </div>
        <div class="card progress-card">
          <h2 class="section-title">📊 Framsteg per avdelning</h2>
          <div class="department-progress-list">
            <div v-for="dept in departmentProgress" :key="dept.name" class="dept-progress-item">
              <div class="dept-header">
                <span class="dept-name">{{ dept.name }}</span>
                <span class="dept-percentage">{{ dept.progress }}%</span>
              </div>
              <div class="progress-bar-container">
                <div class="progress-bar" :style="{ width: dept.progress + '%' }"></div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Employees Tab Content -->
    <div class="tab-content">
      <div v-if="currentTab === 'employees'" class="employees-management">
        <div class="employee-actions">
          <div class="search-bar">
            <span class="search-icon">🔍</span>
            <input type="text" v-model="searchQuery" placeholder="Sök anställda..." class="search-input">
          </div>
          <button class="add-employee-btn">
            <span class="plus-icon">+</span> Lägg till anställd
          </button>
        </div>

        <!-- Employee Detail Panel - UPDATED SECTION -->
        <div v-if="selectedEmployee" class="employee-detail-panel card">
          <div class="detail-header">
            <h2>{{ selectedEmployee.name }}</h2>
            <button class="close-btn" @click="closeEmployeeDetail">✕</button>
          </div>
          <!-- Removed Email Field -->

          <div class="detail-stats-grid">
            <!-- Removed Avdelning and Nivå -->
            <div class="detail-stat">
              <span class="stat-label">Framsteg</span>
              <span class="stat-value progress-stat" :class="selectedEmployee.progress < 60 ? 'progress-low' : 'progress-high'">{{ selectedEmployee.progress }}%</span>
            </div>
            <div class="detail-stat">
              <span class="stat-label">Senast aktiv</span>
              <span class="stat-value">{{ selectedEmployee.lastActive }}</span>
            </div>
          </div>

          <button class="action-button primary-action">Skicka uppföljning</button>
          <button class="action-button">Visa fullständig resultathistorik</button>
        </div>
        <!-- END Employee Detail Panel -->

        <div class="card employee-list-card">
          <h3 class="employee-count">Anställda ({{ filteredEmployees.length }})</h3>

          <div class="employee-table">
            <!-- Table Header - UPDATED: Only Name, Progress, Last Active -->
            <div class="table-row header-row">
              <span class="col col-name">Anställd</span>
              <span class="col col-progress">Framsteg</span>
              <span class="col col-active">Senast aktiv</span>
            </div>

            <!-- Table Rows - UPDATED -->
            <div v-for="employee in filteredEmployees" :key="employee.id"
                 class="table-row data-row clickable-row"
                 @click="selectEmployee(employee)">
              <!-- Name (Email removed from display) -->
              <div class="col col-name employee-info">
                <span :class="['initials-circle', employee.initialsColor]">{{ employee.initials }}</span>
                <div>
                  <div class="employee-name">{{ employee.name }}</div>
                  <!-- Email removed here -->
                </div>
              </div>

              <!-- Progress -->
              <span :class="['col', 'col-progress', employee.progress < 60 ? 'progress-low' : 'progress-high']">{{ employee.progress }}%</span>

              <!-- Last Active -->
              <span class="col col-active">{{ employee.lastActive }}</span>
            </div>

            <!-- Empty State -->
            <div v-if="filteredEmployees.length === 0" class="empty-state-row">
              <div class="col col-name">Ingen anställd matchar sökningen "{{ searchQuery }}".</div>
            </div>
          </div>
        </div>
      </div>

      <p v-else-if="currentTab === 'results'">Detaljerade resultat per användare kommer här.</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';

const currentTab = ref('overview');
const searchQuery = ref('');
// State to hold the currently selected employee for the detail view
const selectedEmployee = ref(null);

// --- LOGIC FOR EMPLOYEE SELECTION ---
const selectEmployee = (employee) => {
  selectedEmployee.value = employee;
};
const closeEmployeeDetail = () => {
  selectedEmployee.value = null;
};
// ------------------------------------

// Mock Data for Admin Summary Cards
const totalEmployees = ref(24);
const newEmployeesThisMonth = ref(2);
const activeTrainings = ref(6);
const newTrainingsThisWeek = ref(3);
const averageScore = ref(78);
const scoreChange = ref(5); // % change
const needFollowUp = ref(3);

// Mock Data for Latest Activity
const latestActivity = ref([
  { id: 1, name: 'Anna Svensson', action: 'Genomförde "E-postsäkerhet"', time: '2 timmar sedan', score: 85 },
  { id: 2, name: 'Erik Johansson', action: 'Startade "Wi-Fi säkerhet"', time: '4 timmar sedan' },
  { id: 3, name: 'Maria Andersson', action: 'Genomförde "Grundläggande cybersäkerhet"', time: '1 dag sedan', score: 92 },
  { id: 4, name: 'Johan Lindberg', action: 'Misslyckades med "Säkra lösenord"', time: '2 dagar sedan', score: 45 },
  { id: 5, name: 'Lisa Karlsson', action: 'Loggade in på plattformen', time: '5 timmar sedan' },
]);

// Mock Data for Department Progress
const departmentProgress = ref([
  { name: 'IT-avdelningen', progress: 95 },
  { name: 'Ekonomi', progress: 78 },
  { name: 'HR', progress: 82 },
  { name: 'Försäljning', progress: 65 },
  { name: 'Marknadsföring', progress: 71 },
]);

// Mock Data for Employee List (Data structure remains the same, but unused fields are ignored by the UI)
const employeeList = ref([
  { id: 1, name: 'Anna Svensson', email: 'anna.s@foretag.se', department: 'HR', level: 'Analyst', initials: 'AS', initialsColor: 'purple', progress: 85, lastActive: '2 timmar sedan' },
  { id: 2, name: 'Erik Johansson', email: 'erik.j@foretag.se', department: 'Försäljning', level: 'Rookie', initials: 'EJ', initialsColor: 'blue', progress: 45, lastActive: '1 dag sedan' },
  { id: 3, name: 'Maria Andersson', email: 'maria.a@foretag.se', department: 'IT-avdelningen', level: 'Responder', initials: 'MA', initialsColor: 'green', progress: 95, lastActive: '30 minuter sedan' },
  { id: 4, name: 'Johan Lindberg', email: 'johan.l@foretag.se', department: 'Ekonomi', level: 'Rookie', initials: 'JL', initialsColor: 'red', progress: 30, lastActive: '3 dagar sedan' },
  { id: 5, name: 'Lisa Karlsson', email: 'lisa.k@foretag.se', department: 'Marknadsföring', level: 'Responder', initials: 'LK', initialsColor: 'orange', progress: 70, lastActive: '5 timmar sedan' },
]);

// Filtered Employees based on search query
const filteredEmployees = computed(() => {
  const query = searchQuery.value.toLowerCase();
  if (!query) {
    return employeeList.value;
  }
  // Search logic remains the same, even if we don't display all fields
  return employeeList.value.filter(employee =>
      employee.name.toLowerCase().includes(query) ||
      employee.email.toLowerCase().includes(query) ||
      employee.department.toLowerCase().includes(query)
  );
});

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

.admin-tabs {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  border-bottom: 1px solid #e0e0e0;
  padding: 0 20px;
}

.tab-button {
  padding: 10px 20px;
  border: none;
  background: transparent;
  cursor: pointer;
  font-weight: 500;
  color: #888;
  border-bottom: 3px solid transparent;
  transition: all 0.2s;
}

.tab-button:hover {
  color: #007bff;
}

.tab-button.active {
  color: #007bff;
  border-bottom: 3px solid #007bff;
  background-color: #f0f0f0; /* Subtle background for active tab */
  border-radius: 8px 8px 0 0;
}

/* --- CARDS (General Styling) --- */
.card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

/* --- SUMMARY GRID LAYOUT (Top Row) --- */
.summary-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); /* Adjusted minmax for four cards */
  gap: 20px;
  margin-bottom: 40px;
}

.summary-card {
  display: flex;
  flex-direction: column;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start; /* Align title and icon to the top */
  margin-bottom: 15px;
}

.summary-card h4 {
  color: #555;
  font-weight: 500;
  margin: 0;
  font-size: 1rem;
}

.icon-employees, .icon-active, .icon-score, .icon-alert {
  font-size: 1.1rem; /* Smaller icon size */
  opacity: 0.8;
}

/* Updated specific icon coloring */
.icon-employees { color: #007bff; }
.icon-active { color: #28a745; }
.icon-score { color: #ffc107; }
.icon-alert { color: #dc3545; }

.main-stat {
  font-size: 2.2rem; /* Slightly smaller for better fit */
  font-weight: 700;
  color: #333;
  margin: 0;
  line-height: 1.2;
}

.sub-stat {
  color: #888;
  font-size: 0.9rem;
  margin-top: 5px;
}

.alert-card {
  /* Subtle red outline instead of border-left */
  border: 1px solid #ffdddd;
  box-shadow: 0 4px 12px rgba(255, 0, 0, 0.05);
}

/* --- DETAILED OVERVIEW GRID (Activity and Progress) --- */
.overview-details-grid {
  display: grid;
  grid-template-columns: 1fr 1fr; /* Two columns */
  gap: 20px;
}

.section-title {
  color: #333;
  font-size: 1.3rem;
  font-weight: 600;
  margin-bottom: 20px;
  padding-bottom: 5px;
}

/* --- LATEST ACTIVITY CARD --- */
.activity-card {
  padding: 30px;
}

.activity-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.activity-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 15px;
  border-bottom: 1px solid #eee;
}
.activity-item:last-child {
  border-bottom: none;
  padding-bottom: 0;
}

.activity-name {
  font-weight: 600;
  color: #333;
  margin: 0;
}

.activity-details {
  font-size: 0.9rem;
  color: #555;
  margin: 3px 0;
}

.activity-time {
  font-size: 0.8rem;
  color: #999;
}

.activity-score {
  font-size: 1rem;
  font-weight: bold;
  padding: 4px 8px;
  border-radius: 6px;
  flex-shrink: 0;
  width: 60px; /* fixed width for alignment */
  text-align: center;
}

.score-high {
  background-color: #d4edda;
  color: #155724;
}

.score-low {
  background-color: #f8d7da;
  color: #721c24;
}

/* --- DEPARTMENT PROGRESS CARD --- */
.progress-card {
  padding: 30px;
}

.department-progress-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.dept-progress-item {
  display: flex;
  flex-direction: column;
}

.dept-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 5px;
  font-weight: 500;
}

.dept-name {
  color: #333;
}

.dept-percentage {
  color: #007bff;
  font-weight: 700;
}

.progress-bar-container {
  height: 10px;
  background-color: #e0e0e0;
  border-radius: 5px;
  overflow: hidden;
}

.progress-bar {
  height: 100%;
  background-color: #007bff; /* Primary color for progress */
  transition: width 0.5s ease-out;
}

/* --- EMPLOYEE MANAGEMENT STYLES --- */

.employees-management {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.employee-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

/* Search Bar */
.search-bar {
  display: flex;
  align-items: center;
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 8px 15px;
  background-color: white;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  flex-grow: 1;
  max-width: 400px;
}

.search-icon {
  font-size: 1.1rem;
  color: #888;
  margin-right: 10px;
}

.search-input {
  border: none;
  outline: none;
  font-size: 1rem;
  width: 100%;
}

/* Add Employee Button */
.add-employee-btn {
  display: flex;
  align-items: center;
  background-color: #007bff;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  font-weight: bold;
  cursor: pointer;
  transition: background-color 0.2s;
  box-shadow: 0 2px 4px rgba(0, 123, 255, 0.3);
}

.add-employee-btn:hover {
  background-color: #0056b3;
}

.plus-icon {
  font-size: 1.2rem;
  margin-right: 5px;
  line-height: 1;
}

/* Employee List Table */
.employee-list-card {
  padding: 0;
  overflow-x: auto;
}

.employee-count {
  font-size: 1.1rem;
  padding: 20px 20px 0 20px;
  margin-bottom: 10px;
  color: #333;
}

.employee-table {
  display: table;
  width: 100%;
  border-collapse: collapse;
}

.table-row {
  display: table-row;
  border-bottom: 1px solid #eee;
}

/* NEW: Clickable row style */
.data-row.clickable-row {
  cursor: pointer;
  transition: background-color 0.15s;
}

.data-row.clickable-row:hover {
  background-color: #eaf6ff; /* A slightly stronger hover effect for clickables */
}

.col {
  display: table-cell;
  padding: 15px 20px;
  text-align: left;
  vertical-align: middle;
}

.header-row {
  background-color: #f8f9fa;
  font-weight: 600;
  color: #555;
  border-bottom: 2px solid #ddd;
  font-size: 0.9rem;
}

/* Column Widths (Adjusted for 3 columns: Name, Progress, Last Active) */
.col-name { width: 50%; }
.col-progress { width: 15%; }
.col-active { width: 35%; }

/* Employee Info */
.employee-info {
  display: flex;
  align-items: center;
  gap: 10px;
  font-weight: 600;
}

.initials-circle {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 0.8rem;
  font-weight: bold;
  flex-shrink: 0;
}

.initials-circle.blue { background-color: #007bff; }
.initials-circle.red { background-color: #dc3545; }
.initials-circle.green { background-color: #28a745; }
.initials-circle.purple { background-color: #6f42c1; }
.initials-circle.orange { background-color: #fd7e14; }

/* The employee-email style is kept but the element is removed from HTML */
.employee-email {
  font-size: 0.8rem;
  font-weight: 400;
  color: #888;
}

/* Removed: Department Badge Styles */
/* Removed: Level Badge Styles */

/* Progress Colors */
.progress-low { color: #dc3545; font-weight: bold; }
.progress-high { color: #28a745; font-weight: bold; }

.empty-state-row {
  display: table-row;
}
.empty-state-row > div {
  display: table-cell;
  text-align: center;
  padding: 40px 20px;
  color: #888;
}

/* --- EMPLOYEE DETAIL PANEL STYLES (NEW) --- */
.employee-detail-panel {
  margin-top: 20px;
  padding: 30px;
  border-left: 5px solid #007bff;
  animation: fadeIn 0.3s ease-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(-10px); }
  to { opacity: 1; transform: translateY(0); }
}

.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.employee-detail-panel h2 {
  margin: 0;
  font-size: 1.5rem;
  color: #333;
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  color: #aaa;
  cursor: pointer;
  transition: color 0.2s;
  padding: 0;
  line-height: 1;
}

.close-btn:hover {
  color: #333;
}

/* detail-email removed from HTML */

.detail-stats-grid {
  display: grid;
  /* Now only two items are left, so we keep the grid dynamic or set to 2 columns */
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-bottom: 30px;
  padding: 15px 0;
  border-top: 1px solid #eee;
  border-bottom: 1px solid #eee;
}

.detail-stat {
  display: flex;
  flex-direction: column;
}

.stat-label {
  font-size: 0.8rem;
  color: #666;
  text-transform: uppercase;
  font-weight: 500;
  margin-bottom: 5px;
}

.stat-value {
  font-size: 1.1rem;
  font-weight: 600;
  color: #333;
}

.progress-stat {
  font-size: 1.2rem;
}

.action-button {
  border: 1px solid #007bff;
  background: white;
  color: #007bff;
  padding: 10px 15px;
  border-radius: 8px;
  margin-right: 10px;
  cursor: pointer;
  transition: all 0.2s;
  font-weight: 500;
}

.action-button:hover {
  background-color: #f0f8ff;
}

.action-button.primary-action {
  background-color: #007bff;
  color: white;
  box-shadow: 0 2px 4px rgba(0, 123, 255, 0.3);
  border: 1px solid #007bff;
}

.action-button.primary-action:hover {
  background-color: #0056b3;
}


/* Responsive adjustments for small screens */
@media (max-width: 768px) {
  .overview-details-grid {
    grid-template-columns: 1fr; /* Stack the two new cards on mobile */
  }

  .employee-actions {
    flex-direction: column;
    align-items: stretch;
    gap: 10px;
  }

  .search-bar {
    max-width: 100%;
  }

  /* Force table to behave more like a list on small screens */
  .employee-table {
    display: block;
  }

  .table-row {
    display: block;
    margin-bottom: 10px;
    border: 1px solid #eee;
    border-radius: 8px;
  }

  .header-row {
    display: none; /* Hide header on mobile */
  }

  .col {
    display: block;
    width: 100% !important;
    padding: 8px 15px;
    border-bottom: 1px dotted #eee;
  }

  .col:last-child {
    border-bottom: none;
  }

  /* Mobile detail panel adjustments */
  .detail-stats-grid {
    grid-template-columns: 1fr;
  }

  .action-button {
    width: 100%;
    margin-right: 0;
    margin-bottom: 10px;
  }
}
</style>
