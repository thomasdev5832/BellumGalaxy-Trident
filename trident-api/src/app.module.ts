import { Module } from '@nestjs/common';
import { GameModule } from './game/game.module';
import { UserModule } from './user/user.module';
import { OrderModule } from './order/order.module';
import { AuthModule } from './auth/auth.module';
import { ConfigModule } from '@nestjs/config';
import { DbModule } from './db/db.module';

@Module({
  imports: [
    ConfigModule.forRoot({isGlobal: true}),
    GameModule, UserModule, OrderModule, AuthModule, DbModule],
  controllers: [],
  providers: [],
})
export class AppModule {}
