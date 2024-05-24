import { Module } from '@nestjs/common';
import { OrderController } from './order.controller';
import { OrderService } from './order.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { OrderEntity } from 'src/db/entities/order.entity';

@Module({
  controllers: [OrderController],
  imports: [TypeOrmModule.forFeature([OrderEntity])],
  exports: [OrderService],
  providers: [OrderService]
})
export class OrderModule {}
