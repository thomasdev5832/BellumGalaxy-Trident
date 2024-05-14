import { Injectable } from '@nestjs/common';

@Injectable()
export class OrderService {
  private orders = [];

  getAllOrders() {
    return this.orders; 
  }

  getOrderById(id: string) {
    return this.orders.find(order => order.id === id); 
  }

  createOrder(orderData: any) {
    const newOrder = { ...orderData, id: (this.orders.length + 1).toString() };
    this.orders.push(newOrder);
    return newOrder;
  }

  updateOrder(id: string, orderData: any) {
    const index = this.orders.findIndex(order => order.id === id); 
    if (index === -1) {
      return null; 
    }
    this.orders[index] = { ...this.orders[index], ...orderData }; 
    return this.orders[index]; 
  }

  deleteOrder(id: string) {
    const index = this.orders.findIndex(order => order.id === id); 
    if (index === -1) {
      return null;
    }
    const deletedOrder = this.orders[index]; 
    this.orders.splice(index, 1);
    return deletedOrder;
  }
}
