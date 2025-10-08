<template>
  <div class="page">
    <h1>CyCure101</h1>
    <p>Välkommen till CyCure101! Här ser du dina utbildningar och framsteg.</p>

    <div class="summary-grid">
      <div class="card summary-card">
        <h4>Nuvarande nivå</h4>
        <div class="status-row">
          <span class="level-badge">Rookie</span>
          <span class="points">{{ currentPoints }} poäng</span>
        </div>
      </div>

      <div class="card summary-card">
        <h4>Framsteg till Analyst</h4>
        <div class="progress-bar-container">
          <div class="progress-bar" :style="{ width: progressPercentage + '%' }"></div>
        </div>
        <div class="status-row">
          <span class="points">{{ currentPoints }} poäng</span>
          <span class="goal-points">{{ goalPoints }} poäng</span>
        </div>
      </div>

      <div class="card summary-card">
        <h4>Genomförda moduler</h4>
        <p class="completed-text">{{ completedModules }} av {{ totalModules }}</p>
        <p class="progress-percent">{{ completionPercentage }}% genomfört</p>
      </div>
    </div>

    <h2>Utbildningsmoduler</h2>

    <div class="modules-grid">
      <div v-for="module in modules" :key="module.id" class="card module-card">
        <div class="module-header">
          <span :class="['module-icon', module.iconClass]">{{ module.icon }}</span>
          <span class="arrow-icon">❯</span>
        </div>

        <h3>{{ module.title }}</h3>
        <p class="description">{{ module.description }}</p>

        <div class="module-details">
          <div class="detail-row">
            <span class="badge">Nybörjare</span>
            <span class="duration">{{ module.duration }}</span>
          </div>
          <p class="points-text">{{ module.points }} poäng</p>
          <p class="status-text">Status: Tillgänglig</p>
        </div>

        <button
            @click="startModule(module.id)"
            class="action-btn btn-start">
          Starta
        </button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      // Summary Stats Data
      currentPoints: 0,
      goalPoints: 400,
      totalModules: 6,
      completedModules: 0,

      // Array to hold the modules (v-for source)
      modules: [
        { id: 1, title: 'Grundläggande cybersäkerhet', description: 'Lär dig grunderna inom cybersäkerhet och vanliga hot', points: 100, duration: '15 min', icon: '🛡️', iconClass: 'shield' },
        { id: 2, title: 'E-postsäkerhet och phishing', description: 'Identifiera och undvik phishing-attacker via e-post', points: 150, duration: '20 min', icon: '✉️', iconClass: 'mail' },
        { id: 3, title: 'Säkra lösenord', description: 'Skapa och hantera starka lösenord säkert', points: 75, duration: '10 min', icon: '🔒', iconClass: 'lock' },
        { id: 4, title: 'Wi-Fi säkerhet', description: 'Förstå riskerna med publika nätverk', points: 50, duration: '5 min', icon: '📶', iconClass: 'wifi' },
        { id: 5, title: 'Mobil säkerhet', description: 'Skydda din telefon och surfplatta', points: 50, duration: '5 min', icon: '📱', iconClass: 'mobile' },
        { id: 6, title: 'Datasäkerhet och backup', description: 'Säkra dina filer och data', points: 75, duration: '15 min', icon: '💾', iconClass: 'data' },
      ]
    };
  },
  computed: {
    // Calculates the progress percentage for the bar
    progressPercentage() {
      return (this.currentPoints / this.goalPoints) * 100;
    },
    completionPercentage() {
      return (this.completedModules / this.totalModules) * 100;
    }
  },
  methods: {
    startModule(id) {
      const module = this.modules.find(m => m.id === id);
      console.log(`Starting module ${id}: ${module.title}!`);
    }
  }
};
</script>

<style scoped>
.page {
  padding: 20px;
  background-color: #f4f7f9; /* Light background for the dashboard area */
}

h1, h2, h3, h4 {
  color: #333;
}

h2 {
  margin-top: 30px;
  margin-bottom: 20px;
}

.card {
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

/* --- SUMMARY GRID LAYOUT (Top 3 Cards) --- */
.summary-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
}

.summary-card h4 {
  color: #555;
  font-weight: normal;
  margin-top: 0;
}

.status-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.level-badge {
  background-color: #e5f0ff;
  color: #007bff;
  padding: 4px 8px;
  border-radius: 4px;
  font-weight: bold;
}

.progress-bar-container {
  height: 8px;
  background-color: #e0e0e0;
  border-radius: 4px;
  margin: 10px 0;
  overflow: hidden;
}

.progress-bar {
  height: 100%;
  background-color: #007bff;
  transition: width 0.5s;
}

.completed-text {
  font-size: 1.5rem;
  font-weight: bold;
  margin: 5px 0;
}

.progress-percent {
  color: #888;
  font-size: 0.9rem;
}

/* --- MODULES GRID LAYOUT (Module Cards) --- */
.modules-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
}

.module-card {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  min-height: 200px;
}

.module-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.module-icon {
  font-size: 2rem;
  line-height: 1;
  color: #007bff;
}

.module-card h3 {
  margin: 10px 0 5px 0;
  color: #333;
}

.description {
  color: #666;
  font-size: 0.9rem;
}

.module-details {
  margin-top: 10px;
}

.detail-row {
  display: flex;
  gap: 10px;
  margin-bottom: 5px;
}

.badge {
  background-color: #d4edda;
  color: #155724;
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 0.8rem;
}

/* --- ACTION BUTTONS --- */
.action-btn {
  padding: 8px 15px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: bold;
  transition: background-color 0.2s;
  margin-top: 15px;
  align-self: flex-start;
}

.btn-start {
  background-color: #007bff;
  color: white;
}

.btn-start:hover {
  background-color: #0056b3;
}
</style>
