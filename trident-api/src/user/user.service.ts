import { Injectable } from '@nestjs/common';
import { UserDto } from './user.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { UserEntity } from 'src/db/entities/user.entity';
import { Repository } from 'typeorm';

@Injectable()
export class UserService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>
  ){}

  async getAllUsers(): Promise<UserDto[]> {
    return this.userRepository.find();
  }

  async getUserById(id: number): Promise<UserDto | undefined> {
    return this.userRepository.findOne({ where: { userId: id } });
  }

  async createUser(userData: UserDto): Promise<UserDto> {
    const newUser = this.userRepository.create(userData);
    return this.userRepository.save(newUser);
  }

  async updateUser(id: number, userData: Partial<UserDto>): Promise<UserDto | null> {
    const user = await this.userRepository.findOne({ where: { userId: id } });
    if (!user) {
      return null;
    }
    this.userRepository.merge(user, userData);
    return this.userRepository.save(user);
  }

  async deleteUser(id: number): Promise<UserDto | null> {
    const user = await this.userRepository.findOne({ where: { userId: id } });
    if (!user) {
      return null;
    }
    await this.userRepository.remove(user);
    return user;
  }

  async findByUserName(username: string): Promise<UserDto | null> {
    return this.userRepository.findOne({ where: { name: username } });
  }
}
