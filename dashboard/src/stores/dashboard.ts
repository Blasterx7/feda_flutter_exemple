import { computed, ref } from 'vue'
import { defineStore } from 'pinia'
import type { CreateShoePayload, Shoe } from '@/types/shoe'
import { createShoeInBackend, fetchShoesFromBackend, getApiBaseUrl } from '@/services/api'

const LOCAL_STORAGE_KEY = 'dashboard_shoes_local'

function loadLocalShoes(): Shoe[] {
  const raw = localStorage.getItem(LOCAL_STORAGE_KEY)
  if (!raw) return []

  try {
    return JSON.parse(raw) as Shoe[]
  } catch {
    return []
  }
}

function saveLocalShoes(shoes: Shoe[]) {
  localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(shoes))
}

export const useDashboardStore = defineStore('dashboard', () => {
  const shoes = ref<Shoe[]>([])
  const loading = ref(false)
  const error = ref('')
  const mode = ref<'backend' | 'local'>('local')

  const totalProducts = computed(() => shoes.value.length)
  const totalStock = computed(() => shoes.value.reduce((sum, item) => sum + item.stock, 0))
  const totalPotentialRevenue = computed(() =>
    shoes.value.reduce((sum, item) => sum + item.price * item.stock, 0),
  )

  async function initialize() {
    loading.value = true
    error.value = ''

    const local = loadLocalShoes()
    shoes.value = local

    try {
      const backendShoes = await fetchShoesFromBackend()
      shoes.value = backendShoes
      mode.value = 'backend'
    } catch {
      mode.value = 'local'
      shoes.value = local
      error.value =
        'Backend local indisponible. Le dashboard fonctionne en mode local pour la démo.'
    } finally {
      loading.value = false
    }
  }

  async function addShoe(payload: CreateShoePayload) {
    error.value = ''

    if (mode.value === 'backend') {
      try {
        const created = await createShoeInBackend(payload)
        shoes.value = [created, ...shoes.value]
        return
      } catch {
        mode.value = 'local'
        error.value =
          'Échec de création backend. Bascule en mode local pour continuer.'
      }
    }

    const createdLocal: Shoe = {
      id: crypto.randomUUID(),
      createdAt: new Date().toISOString(),
      ...payload,
    }
    shoes.value = [createdLocal, ...shoes.value]
    saveLocalShoes(shoes.value)
  }

  function getConnectionLabel() {
    return mode.value === 'backend'
      ? `Connecté au backend (${getApiBaseUrl()})`
      : 'Mode local (fallback)'
  }

  return {
    shoes,
    loading,
    error,
    mode,
    totalProducts,
    totalStock,
    totalPotentialRevenue,
    initialize,
    addShoe,
    getConnectionLabel,
  }
})
