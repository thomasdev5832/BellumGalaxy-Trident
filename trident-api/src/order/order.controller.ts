import { Controller, Get, Post, Put, Delete, Body, Param, HttpException, HttpStatus } from '@nestjs/common';
import { OrderService } from './order.service'; // Importe o serviço de pedido

@Controller('order')
export class OrderController {
  constructor(private readonly orderService: OrderService) {} // Injete o serviço de pedido no controller

  @Get()
  getAllOrders() {
    return this.orderService.getAllOrders();
  }

  @Get(':id')
  getOrderById(@Param('id') id: string) {
    return this.orderService.getOrderById(id);
  }
 @Get('/user/:userId')
 findOrderByUserId(@Param('userId') userId: string){
    return this.orderService.findOrderByUserId(userId)
 }
  @Post()
  createOrder(@Body() orderData: any) {
    console.log('envio post',orderData)      
    if(Object.entries(orderData).length  == 6){
      return this.orderService.createOrder(orderData);
    }
    throw new HttpException(`invalid Payload`, HttpStatus.BAD_REQUEST);
  }

  @Put(':id')
  updateOrder(@Param('id') id: string, @Body() orderData: any) {
    return this.orderService.updateOrder(id, orderData);
  }

  @Delete(':id')
  deleteOrder(@Param('id') id: string) {
    return this.orderService.deleteOrder(id);
  }
}
