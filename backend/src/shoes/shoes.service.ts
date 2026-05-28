import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { CreateShoeDto, Shoe, UpdateShoeDto } from './shoe.model';

@Injectable()
export class ShoesService {
  private shoes: Shoe[] = [
    {
      id: randomUUID(),
      name: 'Air Runner Pro',
      brand: 'NovaSport',
      sellerName: 'Shop Demo',
      price: 45000,
      stock: 12,
      sizes: ['40', '41', '42', '43'],
      description: 'Chaussure légère pour running quotidien.',
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
      createdAt: new Date().toISOString(),
    },
  ];

  findAll(): Shoe[] {
    return [...this.shoes].sort(
      (a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime(),
    );
  }

  findOne(id: string): Shoe {
    const shoe = this.shoes.find((item) => item.id === id);
    if (!shoe) {
      throw new NotFoundException(`Shoe ${id} not found`);
    }
    return shoe;
  }

  create(dto: CreateShoeDto): Shoe {
    this.validatePayload(dto);

    const shoe: Shoe = {
      id: randomUUID(),
      createdAt: new Date().toISOString(),
      ...dto,
      sizes: dto.sizes.map((value) => String(value).trim()).filter(Boolean),
    };

    this.shoes.unshift(shoe);
    return shoe;
  }

  update(id: string, dto: UpdateShoeDto): Shoe {
    const index = this.shoes.findIndex((item) => item.id === id);
    if (index < 0) {
      throw new NotFoundException(`Shoe ${id} not found`);
    }

    const updated: Shoe = {
      ...this.shoes[index],
      ...dto,
      sizes: dto.sizes
        ? dto.sizes.map((value) => String(value).trim()).filter(Boolean)
        : this.shoes[index].sizes,
    };

    this.validatePayload(updated);
    this.shoes[index] = updated;
    return updated;
  }

  remove(id: string): void {
    const index = this.shoes.findIndex((item) => item.id === id);
    if (index < 0) {
      throw new NotFoundException(`Shoe ${id} not found`);
    }

    this.shoes.splice(index, 1);
  }

  private validatePayload(payload: CreateShoeDto | Shoe): void {
    if (!payload.name?.trim()) {
      throw new BadRequestException('name is required');
    }
    if (!payload.brand?.trim()) {
      throw new BadRequestException('brand is required');
    }
    if (!payload.sellerName?.trim()) {
      throw new BadRequestException('sellerName is required');
    }
    if (!payload.description?.trim()) {
      throw new BadRequestException('description is required');
    }
    if (!Array.isArray(payload.sizes) || payload.sizes.length === 0) {
      throw new BadRequestException('sizes must be a non-empty array');
    }
    if (!Number.isFinite(payload.price) || payload.price <= 0) {
      throw new BadRequestException('price must be a positive number');
    }
    if (!Number.isFinite(payload.stock) || payload.stock < 0) {
      throw new BadRequestException('stock must be >= 0');
    }
  }
}
