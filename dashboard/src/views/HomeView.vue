<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { useDashboardStore } from '@/stores/dashboard'

const store = useDashboardStore()

const form = reactive({
  name: '',
  brand: '',
  sellerName: '',
  price: 0,
  stock: 0,
  sizes: '40,41,42',
  description: '',
  imageUrl: '',
})

const submitting = ref(false)

const shoesCountLabel = computed(() => `${store.totalProducts} produit(s)`)

async function submitShoe() {
  if (submitting.value) return
  submitting.value = true

  try {
    await store.addShoe({
      name: form.name.trim(),
      brand: form.brand.trim(),
      sellerName: form.sellerName.trim(),
      price: Number(form.price),
      stock: Number(form.stock),
      sizes: form.sizes
        .split(',')
        .map((value) => value.trim())
        .filter(Boolean),
      description: form.description.trim(),
      imageUrl: form.imageUrl.trim() || undefined,
    })

    form.name = ''
    form.brand = ''
    form.sellerName = ''
    form.price = 0
    form.stock = 0
    form.sizes = '40,41,42'
    form.description = ''
    form.imageUrl = ''
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  store.initialize()
})
</script>

<template>
  <main class="dashboard">
    <header class="dashboard-header">
      <div>
        <h1>Dashboard vendeur · ShoesHub</h1>
        <p>Publiez vos chaussures et suivez votre mini catalogue.</p>
        <RouterLink class="billing-link" to="/billing">
          Gérer mon abonnement SaaS →
        </RouterLink>
        <RouterLink class="billing-link" to="/plans">
          Ouvrir la page client des plans →
        </RouterLink>
      </div>
      <span class="badge" :class="store.mode">{{ store.getConnectionLabel() }}</span>
    </header>

    <p v-if="store.error" class="alert">{{ store.error }}</p>

    <section class="stats-grid">
      <article class="stat-card">
        <h3>Produits</h3>
        <strong>{{ store.totalProducts }}</strong>
        <p>{{ shoesCountLabel }}</p>
      </article>
      <article class="stat-card">
        <h3>Stock total</h3>
        <strong>{{ store.totalStock }}</strong>
        <p>paires disponibles</p>
      </article>
      <article class="stat-card">
        <h3>CA potentiel</h3>
        <strong>{{ store.totalPotentialRevenue.toLocaleString() }} FCFA</strong>
        <p>si tout le stock est vendu</p>
      </article>
    </section>

    <section class="panel">
      <h2>Publier une chaussure</h2>
      <form class="form-grid" @submit.prevent="submitShoe">
        <label>
          Nom
          <input v-model="form.name" required placeholder="Ex: Urban Sprint" />
        </label>

        <label>
          Marque
          <input v-model="form.brand" required placeholder="Ex: StreetWave" />
        </label>

        <label>
          Vendeur
          <input v-model="form.sellerName" required placeholder="Ex: Shop Kora" />
        </label>

        <label>
          Prix (FCFA)
          <input v-model.number="form.price" required type="number" min="1" />
        </label>

        <label>
          Stock
          <input v-model.number="form.stock" required type="number" min="0" />
        </label>

        <label>
          Tailles (CSV)
          <input v-model="form.sizes" required placeholder="40,41,42" />
        </label>

        <label class="full-width">
          URL image
          <input v-model="form.imageUrl" placeholder="https://..." />
        </label>

        <label class="full-width">
          Description
          <textarea
            v-model="form.description"
            required
            rows="3"
            placeholder="Description du modèle"
          />
        </label>

        <div class="full-width form-actions">
          <button :disabled="submitting || store.loading" type="submit">
            {{ submitting ? 'Publication...' : 'Publier la chaussure' }}
          </button>
        </div>
      </form>
    </section>

    <section class="panel">
      <h2>Catalogue vendeur</h2>

      <p v-if="store.loading">Chargement...</p>
      <p v-else-if="store.shoes.length === 0">Aucune chaussure publiée pour le moment.</p>

      <div v-else class="table-wrapper">
        <table>
          <thead>
            <tr>
              <th>Chaussure</th>
              <th>Vendeur</th>
              <th>Tailles</th>
              <th>Prix</th>
              <th>Stock</th>
              <th>Créée le</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="shoe in store.shoes" :key="shoe.id">
              <td>
                <div class="shoe-cell">
                  <img v-if="shoe.imageUrl" :src="shoe.imageUrl" :alt="shoe.name" />
                  <div>
                    <strong>{{ shoe.name }}</strong>
                    <p>{{ shoe.brand }}</p>
                  </div>
                </div>
              </td>
              <td>{{ shoe.sellerName }}</td>
              <td>{{ shoe.sizes.join(', ') }}</td>
              <td>{{ shoe.price.toLocaleString() }} FCFA</td>
              <td>{{ shoe.stock }}</td>
              <td>{{ new Date(shoe.createdAt).toLocaleDateString() }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </main>
</template>

<style scoped>
.dashboard {
  width: min(1200px, 100% - 2rem);
  margin: 0 auto;
  padding: 2rem 0 3rem;
  display: grid;
  gap: 1rem;
}

.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
}

.dashboard-header h1 {
  font-size: 1.6rem;
  font-weight: 700;
}

.dashboard-header p {
  color: #64748b;
}

.billing-link {
  display: inline-block;
  margin-top: 0.45rem;
  color: #0f172a;
  text-decoration: none;
  font-weight: 600;
}

.badge {
  padding: 0.35rem 0.7rem;
  border-radius: 999px;
  font-size: 0.8rem;
  font-weight: 600;
}

.badge.backend {
  background: #dcfce7;
  color: #166534;
}

.badge.local {
  background: #fef3c7;
  color: #92400e;
}

.alert {
  padding: 0.75rem 1rem;
  border: 1px solid #f59e0b;
  background: #fffbeb;
  color: #92400e;
  border-radius: 0.75rem;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 1rem;
}

.stat-card,
.panel {
  border: 1px solid #e2e8f0;
  background: #fff;
  border-radius: 1rem;
  padding: 1rem;
}

.stat-card strong {
  font-size: 1.5rem;
  font-weight: 700;
}

.stat-card p {
  color: #64748b;
  margin-top: 0.3rem;
}

.panel h2 {
  margin-bottom: 1rem;
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
  color: #334155;
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

.form-actions {
  display: flex;
  justify-content: flex-end;
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

.table-wrapper {
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th,
td {
  text-align: left;
  padding: 0.7rem;
  border-bottom: 1px solid #e2e8f0;
  vertical-align: middle;
  white-space: nowrap;
}

.shoe-cell {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.shoe-cell img {
  width: 52px;
  height: 52px;
  object-fit: cover;
  border-radius: 0.5rem;
  border: 1px solid #e2e8f0;
}

.shoe-cell p {
  margin-top: 0.15rem;
  font-size: 0.8rem;
  color: #64748b;
}

@media (max-width: 900px) {
  .form-grid {
    grid-template-columns: 1fr;
  }
}
</style>
