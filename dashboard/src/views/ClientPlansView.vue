<script setup lang="ts">
import { onMounted, onUnmounted, reactive, ref } from 'vue'
import { RouterLink } from 'vue-router'
import type { PublicPlan } from '@/types/saas'
import {
  fetchDirectPaymentStatus,
  fetchPublicPlans,
  payPlanWithPublicKey,
} from '@/services/api'

const PROJECT_PUBLIC_KEY =
  (import.meta.env.VITE_FEDA_PROJECT_PUBLIC_KEY as string | undefined)?.trim() || ''
const PAYMENT_ENV =
  ((import.meta.env.VITE_FEDA_ENV as string | undefined)?.trim().toLowerCase() === 'sandbox'
    ? 'sandbox'
    : 'live') as 'sandbox' | 'live'

const plans = ref<PublicPlan[]>([])
const selectedPlanId = ref('')
const loading = ref(false)
const paying = ref(false)
const errorMessage = ref('')
const successMessage = ref('')
const paymentStatus = ref('')
let pollingInterval: ReturnType<typeof setInterval> | null = null

const customer = reactive({
  firstname: '',
  lastname: '',
  email: '',
  phoneNumber: '',
  country: 'bj',
  paymentMethod: 'mtn_open',
})

const paymentMethods = [
  { label: 'MTN Bénin', value: 'mtn_open' },
  { label: 'Moov Bénin', value: 'moov' },
  { label: 'MTN Côte d\'Ivoire', value: 'mtn_ci' },
  { label: 'Moov Togo', value: 'moov_tg' },
  { label: 'Togocel', value: 'togocel' },
]

async function loadPlans() {
  if (!PROJECT_PUBLIC_KEY) {
    errorMessage.value = 'Variable VITE_FEDA_PROJECT_PUBLIC_KEY manquante.'
    return
  }

  loading.value = true
  errorMessage.value = ''

  try {
    const response = await fetchPublicPlans(PROJECT_PUBLIC_KEY)
    plans.value = response.plans || []
    selectedPlanId.value = plans.value[0]?._id || plans.value[0]?.id || ''
  } catch (error) {
    errorMessage.value =
      error instanceof Error
        ? error.message
        : 'Impossible de charger les plans. Vérifie ash-bwallet et CORS.'
  } finally {
    loading.value = false
  }
}

function getSelectedPlan() {
  return plans.value.find((plan) => {
    const id = plan._id || plan.id || ''
    return id === selectedPlanId.value
  })
}

async function paySelectedPlan() {
  if (!PROJECT_PUBLIC_KEY) {
    errorMessage.value = 'Variable VITE_FEDA_PROJECT_PUBLIC_KEY manquante.'
    return
  }

  const plan = getSelectedPlan()
  if (!plan) {
    errorMessage.value = 'Choisis un plan à payer.'
    return
  }

  if (!customer.firstname || !customer.lastname || !customer.phoneNumber) {
    errorMessage.value = 'Prénom, nom et téléphone sont obligatoires.'
    return
  }

  paying.value = true
  errorMessage.value = ''
  successMessage.value = ''
  paymentStatus.value = ''
  if (pollingInterval) {
    clearInterval(pollingInterval)
    pollingInterval = null
  }

  try {
    const description = `Abonnement ${plan.name} (${plan.interval || 'plan'})`

    const payload = {
      description,
      amount: Number(plan.amount || 0),
      payment_method: customer.paymentMethod,
      use_ussd_prompt: true,
      phone_number: {
        number: customer.phoneNumber,
        country: customer.country,
      },
      firstname: customer.firstname,
      lastname: customer.lastname,
      email: customer.email || undefined,
      callback_url: `${window.location.origin}/plans?payment=success`,
    }

    const result = await payPlanWithPublicKey(PROJECT_PUBLIC_KEY, payload, PAYMENT_ENV)

    const paymentUrl = result.payment_url || result.paymentUrl || ''
    const paymentToken = result.payment_token || result.paymentToken || ''
    const reference = result.reference || 'N/A'
    const status = result.status || 'pending'

    if (payload.use_ussd_prompt) {
      successMessage.value = `Prompt USSD déclenché. Suivez les instructions sur votre téléphone.`
      // Polling sur le statut
      const transactionId = result.id
      if (transactionId) {
        pollingInterval = setInterval(async () => {
          try {
            const statusData = await fetchDirectPaymentStatus(
              transactionId,
              PROJECT_PUBLIC_KEY,
              PAYMENT_ENV,
            )
            paymentStatus.value = statusData.status || 'pending'
            if (paymentStatus.value === 'approved' || paymentStatus.value === 'rejected') {
              clearInterval(pollingInterval!)
              pollingInterval = null
              successMessage.value = `Paiement ${paymentStatus.value === 'approved' ? 'validé' : 'refusé'}!`
            }
          } catch (e) {
            paymentStatus.value = 'Erreur de polling'
          }
        }, 3000)
      }
    } else {
      successMessage.value = paymentToken
        ? `Paiement initialisé (ref: ${reference}, status: ${status}, token: ${paymentToken}).`
        : `Paiement initialisé (ref: ${reference}, status: ${status}).`
      if (paymentUrl) {
        window.location.assign(paymentUrl)
      }
    }
  } catch (error) {
    errorMessage.value =
      error instanceof Error
        ? error.message
        : 'Le paiement a échoué. Vérifie la configuration backend.'
  } finally {
    paying.value = false
  }
}

onMounted(loadPlans)
onUnmounted(() => {
  if (pollingInterval) {
    clearInterval(pollingInterval)
    pollingInterval = null
  }
})
</script>

<template>
  <main class="plans-page">
    <header class="page-header">
      <div>
        <h1>Plans ShoesHub</h1>
        <p>Choisissez un plan et payez directement depuis cette page client.</p>
        <p class="muted">Public key projet: <code>{{ PROJECT_PUBLIC_KEY }}</code></p>
        <p class="env-live">Environnement paiement: {{ PAYMENT_ENV.toUpperCase() }}</p>
      </div>
      <RouterLink class="back-link" to="/">← Retour dashboard</RouterLink>
    </header>

    <section class="card">
      <h2>Plans disponibles</h2>
      <p v-if="loading">Chargement des plans...</p>
      <p v-else-if="plans.length === 0" class="muted">Aucun plan public trouvé.</p>

      <div v-else class="plans-grid">
        <article
          v-for="plan in plans"
          :key="plan._id || plan.id || plan.name"
          class="plan-card"
          :class="{ selected: selectedPlanId === (plan._id || plan.id || '') }"
          @click="selectedPlanId = plan._id || plan.id || ''"
        >
          <h3>{{ plan.name }}</h3>
          <p class="price">
            {{ Number(plan.amount || 0).toLocaleString() }} {{ plan.currency || 'XOF' }}
          </p>
          <p class="muted">{{ plan.interval || 'custom' }}</p>
          <p v-if="plan.description" class="desc">{{ plan.description }}</p>
        </article>
      </div>
    </section>

    <section class="card">
      <h2>Infos client pour payer</h2>
      <div class="form-grid">
        <label>
          Prénom
          <input v-model="customer.firstname" placeholder="Ex: Yao" />
        </label>
        <label>
          Nom
          <input v-model="customer.lastname" placeholder="Ex: Kouassi" />
        </label>
        <label>
          Email (optionnel)
          <input v-model="customer.email" type="email" placeholder="client@email.com" />
        </label>
        <label>
          Téléphone
          <input v-model="customer.phoneNumber" placeholder="+22961000000" />
        </label>
        <label>
          Pays
          <input v-model="customer.country" placeholder="bj" />
        </label>
        <label>
          Opérateur
          <select v-model="customer.paymentMethod">
            <option v-for="method in paymentMethods" :key="method.value" :value="method.value">
              {{ method.label }}
            </option>
          </select>
        </label>
      </div>

      <div class="actions">
        <button :disabled="paying || loading || plans.length === 0" @click="paySelectedPlan">
          {{ paying ? 'Paiement en cours...' : 'Payer le plan sélectionné' }}
        </button>
      </div>

      <p v-if="paymentStatus" class="success">Statut paiement : {{ paymentStatus }}</p>

      <p v-if="errorMessage" class="error">{{ errorMessage }}</p>
      <p v-if="successMessage" class="success">{{ successMessage }}</p>
    </section>

    <section class="card warning">
      <h2>Notes techniques</h2>
      <ul>
        <li>La configuration du paiement est pilotée par les variables d’environnement du dashboard.</li>
        <li>Le backend cible est défini via <code>VITE_ASH_BWALLET_API_BASE_URL</code> et <code>VITE_FEDAPAY_STATUS_API_BASE_URL</code>.</li>
        <li>La clé publique projet est injectée via <code>VITE_FEDA_PROJECT_PUBLIC_KEY</code>.</li>
        <li>Le mode est injecté via <code>VITE_FEDA_ENV</code> (<code>live</code> ou <code>sandbox</code>).</li>
      </ul>
    </section>
  </main>
</template>

<style scoped>
.plans-page {
  width: min(1100px, 100% - 2rem);
  margin: 0 auto;
  padding: 2rem 0 3rem;
  display: grid;
  gap: 1rem;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
}

.page-header h1 {
  font-size: 1.6rem;
  font-weight: 700;
}

.back-link {
  color: #0f172a;
  text-decoration: none;
  font-weight: 600;
}

.card {
  border: 1px solid #e2e8f0;
  background: #fff;
  border-radius: 1rem;
  padding: 1rem;
}

.card h2 {
  margin-bottom: 0.8rem;
  font-size: 1.1rem;
  font-weight: 700;
}

.muted {
  color: #64748b;
}

.env-live {
  margin-top: 0.35rem;
  display: inline-block;
  background: #fee2e2;
  color: #991b1b;
  border: 1px solid #fecaca;
  border-radius: 999px;
  padding: 0.18rem 0.55rem;
  font-size: 0.75rem;
  font-weight: 700;
}

.plans-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 0.75rem;
}

.plan-card {
  border: 1px solid #e2e8f0;
  border-radius: 0.75rem;
  padding: 0.8rem;
  cursor: pointer;
}

.plan-card.selected {
  border-color: #0f172a;
  box-shadow: 0 0 0 2px rgba(15, 23, 42, 0.08);
}

.price {
  margin-top: 0.2rem;
  font-size: 1.2rem;
  font-weight: 700;
}

.desc {
  margin-top: 0.3rem;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 0.75rem;
}

.form-grid label {
  display: grid;
  gap: 0.35rem;
  font-size: 0.85rem;
}

.form-grid input,
.form-grid select {
  border: 1px solid #cbd5e1;
  border-radius: 0.65rem;
  padding: 0.6rem 0.75rem;
  font: inherit;
}

.actions {
  margin-top: 1rem;
}

button {
  border: none;
  background: #0f172a;
  color: white;
  padding: 0.7rem 1rem;
  border-radius: 0.65rem;
  cursor: pointer;
  font-weight: 600;
}

button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.error {
  margin-top: 0.8rem;
  color: #991b1b;
  background: #fef2f2;
  border: 1px solid #fecaca;
  border-radius: 0.65rem;
  padding: 0.6rem 0.7rem;
}

.success {
  margin-top: 0.8rem;
  color: #166534;
  background: #f0fdf4;
  border: 1px solid #bbf7d0;
  border-radius: 0.65rem;
  padding: 0.6rem 0.7rem;
}

.warning {
  background: #fffbeb;
  border-color: #fde68a;
}

.warning ul {
  padding-left: 1rem;
}

@media (max-width: 900px) {
  .form-grid {
    grid-template-columns: 1fr;
  }
}
</style>
