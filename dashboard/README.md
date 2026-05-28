# ShoesHub Seller Dashboard (Template)

Dashboard vendeur Vue 3 prêt à être réutilisé comme template multi-environnements.

## Fonctionnalités

- Dashboard statistiques (produits, stock, CA potentiel)
- Formulaire de publication de chaussures
- Tableau catalogue vendeur
- Intégration backend configurable via variables d’environnement
- Flux SaaS + paiement direct configurable (live/sandbox)

## Démarrage

### 1) Configurer l’environnement

Créer un fichier `.env` à partir de `.env.example`:

```sh
cp .env.example .env
```

Variables principales:

- `VITE_API_BASE_URL`
- `VITE_ASH_BWALLET_API_BASE_URL`
- `VITE_FEDAPAY_STATUS_API_BASE_URL`
- `VITE_FEDA_PROJECT_PUBLIC_KEY`
- `VITE_FEDA_ENV` (`live` ou `sandbox`)

### 2) (Optionnel) Lancer le backend shoes (`lab_app/backend`)

```sh
cd ../backend
npm install
npm run start
```

L’URL effective dépend de `VITE_API_BASE_URL`.

### 3) Lancer le dashboard

```sh
pnpm install
pnpm dev
```

## Configuration API

Le dashboard ne doit pas contenir de clés ni d’URLs hardcodées.

Toutes les connexions backend et paiements passent par les variables d’environnement.

## Tester la page abonnement SaaS

1. Ouvrir `/billing`
2. Vérifier que les variables env sont renseignées
3. Charger les plans et déclencher le paiement

## Vérification qualité

```sh
pnpm lint
pnpm build
```
