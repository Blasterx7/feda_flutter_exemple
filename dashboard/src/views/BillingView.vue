<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import type { PublicPlan } from '@/types/saas'
import {
  fetchCurrentSubscription,
  fetchPublicPlans,
  getAshBwalletApiBaseUrl,
  getAshBwalletToken,
  setAshBwalletToken,
  startSaasUpgrade,
} from '@/services/api'

const publicKey = ref(
  (import.meta.env.VITE_FEDA_PROJECT_PUBLIC_KEY as string | undefined)?.trim() || '',
)
const userId = ref((import.meta.env.VITE_SAAS_USER_ID as string | undefined)?.trim() || 'seller-demo-001')
const token = ref('')

const plans = ref<PublicPlan[]>([])
const selectedPlanId = ref('')
const loadingPlans = ref(false)
const paying = ref(false)
const errorMessage = ref('')
const infoMessage = ref('')
const subscriptionStatus = ref('unknown')

const knownIssues = [
  {
    title: 'Endpoint upgrade non lié au plan sélectionné',
    detail:
      'Actuellement, `POST /saas/upgrade` ne prend pas de `planId` en entrée (prix fixe dans le backend).',
    correction:
      'Ajouter `planId` dans la payload backend et calculer le montant selon ce plan.',
  },
  {
    title: 'Contexte utilisateur requis',
    detail:
      'Le backend a besoin d’un JWT valide (`req.user`) pour upgrader un abonnement SaaS.',
    correction:
      'Brancher Keycloak côté dashboard et injecter automatiquement le token Bearer.',
  },
  {
    title: 'Callback paiement figé',
    detail:
      'La redirection de succès dépend de `FRONTEND_URL` backend et peut diverger de l’URL réelle du dashboard.',
    correction:
      'Paramétrer dynamiquement l’URL de callback par environnement/deploy.',
  },
  {
    title: 'Idempotence paiement',
    detail:
      'Un double-clic ou refresh peut créer des transactions doublons.',
    correction:
      'Ajouter une clé d’idempotence côté backend + verrou côté UI.',
  },
]

async function loadPlans() {
  if (!publicKey.value.trim()) {
    errorMessage.value = 'Veuillez renseigner une publicKey projet.'
    return
  }

  loadingPlans.value = true
  errorMessage.value = ''
  infoMessage.value = ''

  try {
    const [plansResponse, currentSub] = await Promise.all([
      fetchPublicPlans(publicKey.value.trim()),
      fetchCurrentSubscription(publicKey.value.trim(), userId.value.trim()),
    ])

    plans.value = plansResponse.plans || []
    selectedPlanId.value = plans.value[0]?._id || plans.value[0]?.id || ''
    subscriptionStatus.value = currentSub.status || 'none'

    if (plans.value.length === 0) {
      infoMessage.value = 'Aucun plan public disponible pour ce projet.'
    }
  } catch (error) {
    errorMessage.value =
      error instanceof Error
        ? error.message
        : 'Impossible de charger les plans depuis ash-bwallet.'
  } finally {
    loadingPlans.value = false
  }
}

async function paySelectedPlan() {
  if (!selectedPlanId.value) {
    errorMessage.value = 'Sélectionnez un plan avant de payer.'
    return
  }

  if (!token.value.trim()) {
    errorMessage.value = 'Un token JWT ash-bwallet est requis pour démarrer le paiement.'
    return
  }

  paying.value = true
  errorMessage.value = ''
  infoMessage.value = ''

  try {
    setAshBwalletToken(token.value.trim())

    const result = await startSaasUpgrade()

    if (result.paymentUrl) {
      infoMessage.value = 'Redirection vers la page de paiement...'
      window.location.href = result.paymentUrl
      return
    }

    if (result.success) {
      infoMessage.value = 'Upgrade appliqué (mode fallback backend).'
      return
    }

    errorMessage.value = 'Paiement non lancé: aucune URL retournée.'
  } catch (error) {
    errorMessage.value =
      error instanceof Error ? error.message : 'Échec du déclenchement du paiement.'
  } finally {
    paying.value = false
  }
}

onMounted(() => {
  token.value = getAshBwalletToken()
})
</script>

<template>
  <main class="billing-page">
    <header class="page-header">
      <div>
        <h1>Abonnements SaaS</h1>
        <p>Choisissez un plan et déclenchez automatiquement le paiement.</p>
      </div>
      <RouterLink class="back-link" to="/">← Retour dashboard vendeur</RouterLink>
    </header>

    <section class="card">
      <h2>Contexte de connexion ash-bwallet</h2>
      <p class="muted">Base API: {{ getAshBwalletApiBaseUrl() }}</p>

      <div class="form-grid">
        <label>
          Public Key projet
          <input v-model="publicKey" placeholder="pk_xxxxxxxxx" />
        </label>

        <label>
          User ID client (lecture souscription)
          <input v-model="userId" placeholder="seller-demo-001" />
        </label>

        <label class="full-width">
          JWT ash-bwallet (Bearer)
          <textarea
            v-model="token"
            rows="3"
            placeholder="eyJhbGciOi..."
          />
        </label>
      </div>

      <div class="actions">
        <button :disabled="loadingPlans" @click="loadPlans">
          {{ loadingPlans ? 'Chargement...' : 'Charger les plans' }}
        </button>
      </div>

      <p v-if="subscriptionStatus !== 'unknown'" class="status">
        Statut de souscription actuel: <strong>{{ subscriptionStatus }}</strong>
      </p>

      <p v-if="errorMessage" class="error">{{ errorMessage }}</p>
      <p v-if="infoMessage" class="info">{{ infoMessage }}</p>
    </section>

    <section class="card">
      <h2>Choix du plan</h2>

      <p v-if="plans.length === 0" class="muted">
        Aucun plan chargé pour le moment.
      </p>

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
          <p class="muted">
            {{ plan.interval || 'custom' }}
            <span v-if="plan.trialDays">· Essai {{ plan.trialDays }} jours</span>
          </p>
          <p v-if="plan.description" class="desc">{{ plan.description }}</p>
        </article>
      </div>

      <div class="actions">
        <button :disabled="paying || plans.length === 0" @click="paySelectedPlan">
          {{ paying ? 'Paiement en cours...' : 'Payer automatiquement ce plan' }}
        </button>
      </div>
    </section>

    <section class="card issues">
      <h2>Problèmes relevés & corrections à faire</h2>
      <article v-for="issue in knownIssues" :key="issue.title" class="issue-item">
        <h3>{{ issue.title }}</h3>
        <p><strong>Constat:</strong> {{ issue.detail }}</p>
        <p><strong>Correction:</strong> {{ issue.correction }}</p>
      </article>
    </section>
  </main>
</template>

<style scoped>
.billing-page {
  width: min(1100px, 100% - 2rem);
  margin: 0 auto;
  padding: 2rem 0 3rem;
  display: grid;
  gap: 1rem;
}

.page-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 1rem;
}

.page-header h1 {
  font-size: 1.6rem;
  font-weight: 700;
}

.page-header p {
  color: #64748b;
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
.form-grid textarea {
  border: 1px solid #cbd5e1;
  border-radius: 0.65rem;
  padding: 0.6rem 0.75rem;
  font: inherit;
}

.full-width {
  grid-column: 1 / -1;
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
  margin-top: 0.4rem;
  color: #334155;
  font-size: 0.9rem;
}

.status {
  margin-top: 0.8rem;
}

.muted {
  color: #64748b;
}

.error {
  margin-top: 0.8rem;
  color: #991b1b;
  background: #fef2f2;
  border: 1px solid #fecaca;
  border-radius: 0.65rem;
  padding: 0.6rem 0.7rem;
}

.info {
  margin-top: 0.8rem;
  color: #1d4ed8;
  background: #eff6ff;
  border: 1px solid #bfdbfe;
  border-radius: 0.65rem;
  padding: 0.6rem 0.7rem;
}

.issues {
  background: #fffbeb;
  border-color: #fde68a;
}

.issue-item {
  padding: 0.65rem 0;
  border-bottom: 1px dashed #fcd34d;
}

.issue-item:last-child {
  border-bottom: none;
}

.issue-item h3 {
  font-size: 0.98rem;
  font-weight: 700;
  margin-bottom: 0.2rem;
}

@media (max-width: 900px) {
  .form-grid {
    grid-template-columns: 1fr;
  }
}
</style>
