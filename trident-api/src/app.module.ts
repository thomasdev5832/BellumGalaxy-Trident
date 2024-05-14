import { Module } from '@nestjs/common';
import { GameModule } from './game/game.module';
import { UserModule } from './user/user.module';
import { OrderModule } from './order/order.module';

@Module({
  imports: [GameModule, UserModule, OrderModule],
  controllers: [],
  providers: [],
})
export class AppModule {}
