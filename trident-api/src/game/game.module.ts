import { Module } from '@nestjs/common';
import { GameController } from './game.controller';
import { GameService } from './game.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { GameEntity } from 'src/db/entities/game.entity';

@Module({
  controllers: [GameController],
  imports: [TypeOrmModule.forFeature([GameEntity])],
  exports: [GameService],
  providers: [GameService]
})
export class GameModule {}
