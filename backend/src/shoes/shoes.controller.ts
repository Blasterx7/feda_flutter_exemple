import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Post,
} from '@nestjs/common';
import { ShoesService } from './shoes.service';
import type { CreateShoeDto, UpdateShoeDto } from './shoe.model';

@Controller('shoes')
export class ShoesController {
  constructor(private readonly shoesService: ShoesService) {}

  @Get()
  findAll() {
    return this.shoesService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.shoesService.findOne(id);
  }

  @Post()
  create(@Body() dto: CreateShoeDto) {
    return this.shoesService.create(dto);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateShoeDto) {
    return this.shoesService.update(id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: string) {
    this.shoesService.remove(id);
  }
}
