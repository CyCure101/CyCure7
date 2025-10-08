import axios from 'axios'

const API_BASE_URL = 'http://localhost:3000/api'

const apiService = {
  async register(userData) {
    const response = await axios.post(`${API_BASE_URL}/register`, userData)
    return response.data
  },

  async login(credentials) {
    const response = await axios.post(`${API_BASE_URL}/login`, credentials, {
      withCredentials: true
    })
    return response.data
  },

  async logout() {
    const response = await axios.post(`${API_BASE_URL}/logout`, {}, {
      withCredentials: true
    })
    return response.data
  },

  async getCurrentUser() {
    const response = await axios.get(`${API_BASE_URL}/me`, {
      withCredentials: true
    })
    return response.data
  },

  async getQuizzes() {
    const response = await axios.get(`${API_BASE_URL}/quizzes`)
    return response.data
  },

  async getQuiz(quizId) {
    const response = await axios.get(`${API_BASE_URL}/quizzes/${quizId}`)
    return response.data
  },

  async getQuizQuestions(quizId) {
    const response = await axios.get(`${API_BASE_URL}/quizzes/${quizId}/questions`)
    return response.data
  }
}

export default apiService
