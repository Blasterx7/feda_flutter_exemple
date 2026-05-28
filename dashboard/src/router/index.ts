import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import BillingView from '../views/BillingView.vue'
import ClientPlansView from '../views/ClientPlansView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'dashboard',
      component: HomeView,
    },
    {
      path: '/billing',
      name: 'billing',
      component: BillingView,
    },
    {
      path: '/plans',
      name: 'plans',
      component: ClientPlansView,
    },
  ],
})

export default router
