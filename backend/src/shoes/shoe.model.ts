export interface Shoe {
  id: string;
  name: string;
  brand: string;
  sellerName: string;
  price: number;
  stock: number;
  sizes: string[];
  description: string;
  imageUrl?: string;
  createdAt: string;
}

export interface CreateShoeDto {
  name: string;
  brand: string;
  sellerName: string;
  price: number;
  stock: number;
  sizes: string[];
  description: string;
  imageUrl?: string;
}

export type UpdateShoeDto = Partial<CreateShoeDto>;
