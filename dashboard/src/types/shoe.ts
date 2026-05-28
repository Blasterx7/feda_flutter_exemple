export interface Shoe {
  id: string
  name: string
  brand: string
  sellerName: string
  price: number
  stock: number
  sizes: string[]
  description: string
  imageUrl?: string
  createdAt: string
}

export interface CreateShoePayload {
  name: string
  brand: string
  sellerName: string
  price: number
  stock: number
  sizes: string[]
  description: string
  imageUrl?: string
}
