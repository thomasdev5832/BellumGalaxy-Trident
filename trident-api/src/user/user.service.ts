import { Injectable } from '@nestjs/common';
import { UserDto } from './user.dto';

@Injectable()
export class UserService {
  private users: UserDto[] = [];

  getAllUsers() {
    return this.users; 
  }

  getUserById(id: string) {
    return this.users.find(user => user.id === id);
  }

  createUser(userData: UserDto) {
    const newUser = { ...userData, id: (this.users.length + 1).toString() };
    this.users.push(newUser); 
    return newUser;
  }

  updateUser(id: string, userData: any) {
    const index = this.users.findIndex(user => user.id === id);
    if (index === -1) {
      return null; 
    }
    this.users[index] = { ...this.users[index], ...userData }; 
    return this.users[index]; 
  }

  deleteUser(id: string) {
    const index = this.users.findIndex(user => user.id === id);
    if (index === -1) {
      return null;
    }
    const deletedUser = this.users[index]; 
    this.users.splice(index, 1); 
    return deletedUser; 
  }

  findByUserName(username: string): UserDto | null {
    return this.users.find(user => user.username == username);
  }
}
