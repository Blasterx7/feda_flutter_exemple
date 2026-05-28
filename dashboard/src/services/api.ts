import type { CreateShoePayload, Shoe } from '@/types/shoe'
import type {
  CurrentSubscriptionResponse,
  PublicPlansResponse,
  SaasUpgradeResponse,
} from '@/types/saas'

export interface DirectPaymentPayload {
  description: string
  amount: number
  payment_method: string
  use_ussd_prompt?: boolean
  phone_number: {
    number: string
    country?: string
  }
  firstname: string
  lastname: string
  email?: string
  callback_url?: string
}

export interface DirectPaymentResponse {
  ok?: boolean
  id?: string
  reference?: string
  status?: string
  description?: string
  amount?: number
  payment_url?: string
  payment_token?: string
  paymentUrl?: string
  paymentToken?: string
}

export interface TransactionStatusResponse {
  transactionId?: number | string
  status?: string
  amount?: number
  currency?: string | { iso?: string }
  approved_at?: string | null
  description?: string
  message?: string
  raw?: Record<string, unknown>
}

const SHOES_API_BASE_URL =
  (import.meta.env.VITE_API_BASE_URL as string | undefined)?.trim() ||
  'http://localhost:3000'

const ASH_BWALLET_API_BASE_URL =
  (import.meta.env.VITE_ASH_BWALLET_API_BASE_URL as string | undefined)?.trim() ||
  'http://localhost:3005'

const FEDAPAY_STATUS_API_BASE_URL =
  (import.meta.env.VITE_FEDAPAY_STATUS_API_BASE_URL as string | undefined)?.trim() ||
  ASH_BWALLET_API_BASE_URL

function getAuthHeaders(tokenStorageKey = 'dashboard_jwt') {
  const token = localStorage.getItem(tokenStorageKey)
  if (!token) return undefined
  return { Authorization: `Bearer ${token}` }
}

async function requestJson<T>(
  baseUrl: string,
  path: string,
  init?: RequestInit,
  tokenStorageKey?: string,
): Promise<T> {
  const headers = new Headers(init?.headers)
  headers.set('Content-Type', 'application/json')

  const authHeaders = getAuthHeaders(tokenStorageKey)
  if (authHeaders?.Authorization) {
    headers.set('Authorization', authHeaders.Authorization)
  }

  const response = await fetch(`${baseUrl}${path}`, {
    ...init,
    headers,
  })

  if (!response.ok) {
    const body = await response.text()
    throw new Error(`HTTP ${response.status} on ${path}: ${body || response.statusText}`)
  }

  if (response.status === 204) return undefined as T

  return (await response.json()) as T
}

function normalizeShoe(raw: Record<string, unknown>): Shoe {
  const sizesRaw = raw.sizes
  const normalizedSizes = Array.isArray(sizesRaw)
    ? sizesRaw.map((value) => String(value))
    : String(raw.size || '40,41,42')
        .split(',')
        .map((value) => value.trim())
        .filter(Boolean)

  return {
    id: String(raw.id || raw._id || crypto.randomUUID()),
    name: String(raw.name || raw.title || 'Chaussure'),
    brand: String(raw.brand || 'N/A'),
    sellerName: String(raw.sellerName || raw.ownerName || raw.seller || 'Vendeur'),
    price: Number(raw.price || 0),
    stock: Number(raw.stock || 0),
    sizes: normalizedSizes,
    description: String(raw.description || ''),
    imageUrl: raw.imageUrl ? String(raw.imageUrl) : undefined,
    createdAt: String(raw.createdAt || new Date().toISOString()),
  }
}

export async function fetchShoesFromBackend(): Promise<Shoe[]> {
  const result = await requestJson<Record<string, unknown>[]>(
    SHOES_API_BASE_URL,
    '/shoes',
  )
  return result.map((item) => normalizeShoe(item))
}

export async function createShoeInBackend(payload: CreateShoePayload): Promise<Shoe> {
  const result = await requestJson<Record<string, unknown>>(
    SHOES_API_BASE_URL,
    '/shoes',
    {
      method: 'POST',
      body: JSON.stringify(payload),
    },
  )
  return normalizeShoe(result)
}

export function getApiBaseUrl() {
  return SHOES_API_BASE_URL
}

export function getAshBwalletApiBaseUrl() {
  return ASH_BWALLET_API_BASE_URL
}

export function setAshBwalletToken(token: string) {
  localStorage.setItem('ash_bwallet_jwt', token)
}

export function getAshBwalletToken() {
  return localStorage.getItem('ash_bwallet_jwt') || ''
}

export async function fetchPublicPlans(publicKey: string): Promise<PublicPlansResponse> {
  return requestJson<PublicPlansResponse>(
    ASH_BWALLET_API_BASE_URL,
    `/public/plans/${encodeURIComponent(publicKey)}`,
  )
}

export async function fetchCurrentSubscription(
  publicKey: string,
  userId: string,
): Promise<CurrentSubscriptionResponse> {
  const query = new URLSearchParams({ userId }).toString()
  return requestJson<CurrentSubscriptionResponse>(
    ASH_BWALLET_API_BASE_URL,
    `/public/subscriptions/${encodeURIComponent(publicKey)}/current?${query}`,
  )
}

export async function startSaasUpgrade(): Promise<SaasUpgradeResponse> {
  return requestJson<SaasUpgradeResponse>(
    ASH_BWALLET_API_BASE_URL,
    '/saas/upgrade',
    { method: 'POST' },
    'ash_bwallet_jwt',
  )
}

export async function payPlanWithPublicKey(
  publicKey: string,
  payload: DirectPaymentPayload,
  environment: 'sandbox' | 'live' = 'live',
): Promise<DirectPaymentResponse> {
  return requestJson<DirectPaymentResponse>(
    ASH_BWALLET_API_BASE_URL,
    '/fedapay/direct-payment',
    {
      method: 'POST',
      headers: {
        'x-feda-project-key': publicKey,
        'x-feda-env': environment,
      },
      body: JSON.stringify(payload),
    },
  )
}

export async function fetchDirectPaymentStatus(
  transactionId: string | number,
  publicKey: string,
  environment: 'sandbox' | 'live',
): Promise<TransactionStatusResponse> {
  return requestJson<TransactionStatusResponse>(
    FEDAPAY_STATUS_API_BASE_URL,
    `/fedapay/transaction/${encodeURIComponent(String(transactionId))}/status`,
    {
      method: 'GET',
      headers: {
        'x-feda-project-key': publicKey,
        'x-feda-env': environment,
      },
    },
  )
}
