import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { OrderEntity } from 'src/db/entities/order.entity';
import { Repository } from 'typeorm';
import { OrderDto } from './order.dto';
import { plainToClass } from 'class-transformer';

@Injectable()
export class OrderService {
  constructor(
    @InjectRepository(OrderEntity)
    private readonly orderRepository: Repository<OrderEntity>,
  ) {}
  async getAllOrders() {
    return  await this.orderRepository.find()
  }
  async getOrderById(id: string) {
    return await this.orderRepository.findOne({ where: { id } });
  }
  async createOrder(orderData: OrderDto) {
    const orderEntity = plainToClass(OrderEntity, orderData); // transform gameData to GameEntity
    orderEntity.user = { userId: orderData.userId } as any;
    orderEntity.game = { gameId: orderData.gameId} as any; // Adapt to ManyToOne
    return await this.orderRepository.save(orderEntity);
  }

  async updateOrder(id: string, orderData: OrderDto) {
    const order = await this.getOrderById(id)
    if (!order) {
      throw new HttpException(`Order with id ${id} not found`, HttpStatus.NOT_FOUND);
    }
    Object.assign(order, orderData);
    return await this.orderRepository.save(order);
  }

  async deleteOrder(id: string) {
    const order = await this.getOrderById(id);
    if (!order) {
      throw new HttpException(`Order with id ${id} not found`, HttpStatus.NOT_FOUND);
    }
    await this.orderRepository.delete(id);
    return order;
  }
}
