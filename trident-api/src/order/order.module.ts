import { Module } from '@nestjs/common';
import { OrderController } from './order.controller';
import { OrderService } from './order.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { OrderEntity } from 'src/db/entities/order.entity';
import { UserEntity } from 'src/db/entities/user.entity';
import { UserService } from 'src/user/user.service';
import { GameEntity } from 'src/db/entities/game.entity';
import { GameService } from 'src/game/game.service';

@Module({
  controllers: [OrderController],
  imports: [TypeOrmModule.forFeature([OrderEntity, UserEntity, GameEntity])],
  exports: [OrderService],
  providers: [OrderService, UserService, GameService]
})
export class OrderModule { }
