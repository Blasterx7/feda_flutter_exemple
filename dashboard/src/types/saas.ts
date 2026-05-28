export interface PublicPlan {
  _id?: string
  id?: string
  name: string
  amount: number
  currency?: string
  interval?: 'monthly' | 'yearly' | string
  trialDays?: number
  isPublic?: boolean
  description?: string
}

export interface PublicPlansResponse {
  projectId: string
  plans: PublicPlan[]
}

export interface CurrentSubscriptionResponse {
  success: boolean
  subscription: Record<string, unknown> | null
  hasActiveSubscription: boolean
  status: string
}

export interface SaasUpgradeResponse {
  paymentUrl?: string | null
  success?: boolean
  subscription?: Record<string, unknown>
}
