import {createRouter, createWebHistory} from 'vue-router'
import Home from '../views/Home.vue'
import Login from '../views/Login.vue'
import Register from '../views/Register.vue'
import Quiz from '../views/Quiz.vue'
import Results from '../views/Results.vue'
import MyResults from '../views/MyResults.vue'

const routes = [
    {
        path: '/',
        name: 'Home',
        component: Home
    },
    {
        path: '/login',
        name: 'Login',
        component: Login
    },
    {
        path: '/register',
        name: 'Register',
        component: Register
    },
    {
        path: '/quiz/:id',
        name: 'Quiz',
        component: Quiz
    },
    {
        path: '/quiz/:id/results/:attemptId',
        name: 'Results',
        component: Results
    },
    {
        path: '/quiz/:id/theory',
        name: 'Teori',
        component: () => import('../views/Theory.vue')
    },
    {
        path: '/MyResults',
        name: 'MyResults',
        component: MyResults
    }

]

const router = createRouter({
    history: createWebHistory(),
    routes
})

export default router


