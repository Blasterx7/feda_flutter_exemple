import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ShoesController } from './shoes/shoes.controller';
import { ShoesService } from './shoes/shoes.service';

@Module({
  imports: [],
  controllers: [AppController, ShoesController],
  providers: [AppService, ShoesService],
})
export class AppModule {}
