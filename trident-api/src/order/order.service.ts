import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { OrderEntity } from 'src/db/entities/order.entity';
import { Repository } from 'typeorm';
import { OrderDto } from './order.dto';
import { plainToClass } from 'class-transformer';
import { UserService } from 'src/user/user.service';
import { GameService } from 'src/game/game.service';

@Injectable()
export class OrderService {
  constructor(
    @InjectRepository(OrderEntity)
    private readonly orderRepository: Repository<OrderEntity>,
    private readonly userService: UserService,
    private readonly gameService: GameService


  ) { }
  async getAllOrders(id:string) {
    return await this.orderRepository.find({where:{user:{userId: id}}})
  }
  async getOrderByIdOnCreate(id: string) {
    return await this.orderRepository.findOne({ where: { id } });
  }
  async getOrderById(id: string,userId:string) {
    return await this.orderRepository.findOne({ where: { id, user:{userId} } });
  }
  async createOrder(orderData: OrderDto) {

    orderData.previousOwner = orderData.previousOwner == '0000000000000000000000000000000000000' ? "empty" : orderData.previousOwner;
    let orderEntity = plainToClass(OrderEntity, orderData);
    let previousOwnerOrder = plainToClass(OrderEntity, orderData);
    let arrayReturn = [];

    const userPreviusOwner = await this.userService.findByUserWallerId(orderData.previousOwner) || null;
    const userReceiver = await this.userService.findByUserWallerId(orderData.receiver) || null;
    const game = await this.gameService.findGameByName(orderData.gameName);

    if (!userReceiver) {
      throw new HttpException(`Order with userReceiver ${orderData.receiver} not found`, HttpStatus.NOT_FOUND);
    }
    if (!game) {
      throw new HttpException(`Order with gameName ${orderData.gameName} not found`, HttpStatus.NOT_FOUND);
    }

    if (userPreviusOwner) {
      const existingOrderPreviusOwner = await this.findOrderByUserIdAndGameId(userPreviusOwner.userId, game.gameId) || null;
      let resultPrevius = null;
      previousOwnerOrder.game = { gameId: game.gameId } as any;
      previousOwnerOrder.user = { userId: userPreviusOwner.userId } as any;
      previousOwnerOrder.isBlocked = true;

      if (existingOrderPreviusOwner) {
        resultPrevius = await this.updateOrderOnCreate(existingOrderPreviusOwner.id, { ...previousOwnerOrder, gameId: game.gameId, userId: userPreviusOwner.userId });
      } else {
        resultPrevius = await this.orderRepository.save(previousOwnerOrder);
      }
      arrayReturn.push({ "previusOwner": resultPrevius });
    }

    const existingOrderReceiver = await this.findOrderByUserIdAndGameId(userReceiver.userId, game.gameId) || null;
    let resultReceive = null;
    orderEntity.game = { gameId: game.gameId } as any;
    orderEntity.user = { userId: userReceiver.userId } as any;
    orderEntity.isBlocked = false;

    if (existingOrderReceiver) {
      resultReceive = await this.updateOrderOnCreate(existingOrderReceiver.id, { ...orderEntity, gameId: game.gameId, userId: userReceiver.userId });
    } else {
      resultReceive = await this.orderRepository.save(orderEntity);
    }

    arrayReturn.push({ "Receiver": resultReceive });
    return arrayReturn;
  }

  async updateOrderOnCreate(id: string, orderData: OrderDto) {
    const order = await this.getOrderByIdOnCreate(id)
    if (!order) {
      throw new HttpException(`Order with id ${id} not found`, HttpStatus.NOT_FOUND);
    }
    Object.assign(order, orderData);
    return await this.orderRepository.save(order);
  }
  async updateOrder(id: string, orderData: OrderDto,userId) {
    const order = await this.getOrderById(id,userId)
    if (!order) {
      throw new HttpException(`Order with id ${id} not found`, HttpStatus.NOT_FOUND);
    }
    Object.assign(order, orderData);
    return await this.orderRepository.save(order);
  }
  async findOrderByUserIdAndGameId(userId: string, gameId: string): Promise<OrderEntity> {
    return await this.orderRepository.findOne({
      where: {
        user: { userId },
        game: { gameId }
      }
    });
  }
  async findOrderByUserId(userId: string): Promise<OrderEntity[]> {
    console.log('userId', userId)
    let result = []
    const orderUser = await this.orderRepository.find({ where: { user:{userId} } });

    for(let i = 0; i < orderUser.length; i++){
      const game = await this.gameService.findGameByGameAddress(orderUser[i].gameAddress)
      console.log(game)
      result.push({
        ...game,
        ...orderUser[i]
      })
    }  
    return result

  }
  async deleteOrder(id: string,userId:string) {
    const order = await this.getOrderById(id,userId);
    if (!order) {
      throw new HttpException(`Order with id ${id} not found`, HttpStatus.NOT_FOUND);
    }
    await this.orderRepository.delete(id);
    return order;
  }
}
