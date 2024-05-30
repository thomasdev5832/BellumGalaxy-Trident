import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { GameDto } from './game.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { GameEntity } from 'src/db/entities/game.entity';
import { plainToClass } from 'class-transformer';

@Injectable()
export class GameService {

  constructor(
    @InjectRepository(GameEntity)
    private readonly gameRepository: Repository<GameEntity>,
  ) {}

  async getAllGames(): Promise<GameEntity[]> {
    return await this.gameRepository.find();
  }

  async getGameById(id: string): Promise<GameEntity> {
    const game = await this.gameRepository.findOne({ where: { gameId: id } });
    if (!game) {
      throw new HttpException(`Game with id ${id} not found`, HttpStatus.NOT_FOUND);
    }
    return game;
  }

  async createGame(gameData: GameDto): Promise<GameEntity> {
    const gameEntity = plainToClass(GameEntity, gameData); // transform gameData to GameEntity
    return await this.gameRepository.save(gameEntity);
  }

  async updateGame(id: string, gameData: GameDto): Promise<GameEntity> {
    const game = await this.getGameById(id);
    if (!game) {
      throw new HttpException(`Game with id ${id} not found`, HttpStatus.NOT_FOUND);
    }
    Object.assign(game, gameData);
    return await this.gameRepository.save(game);
  }

  
  async deleteGame(id: string): Promise<GameEntity> {
    const game = await this.getGameById(id);
    if (!game) {
      throw new HttpException(`Game with id ${id} not found`, HttpStatus.NOT_FOUND);
    }
    await await this.gameRepository.delete(id);
    return game;
  }

  async findGameByName(name:string): Promise<GameEntity>{
    const game = await this.gameRepository.findOne({ where: { name } });

    if (!game) {
      throw new HttpException(`Game with name ${name} not found`, HttpStatus.NOT_FOUND);
    }
    return game
  }
  async findGameByGameAddress(gameAddress:string): Promise<GameEntity>{
    const game = await this.gameRepository.findOne({ where: { gameAddress } });

    if (!game) {
      throw new HttpException(`Game with name ${name} not found`, HttpStatus.NOT_FOUND);
    }
    return game
  }
}
