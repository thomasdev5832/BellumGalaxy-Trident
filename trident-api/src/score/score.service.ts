import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { ScoreEntity } from 'src/db/entities/score.entity';
import { Repository } from 'typeorm';
import { ScoreDto } from './score.dto';
import { plainToClass } from 'class-transformer';

@Injectable()
export class ScoreService {
  constructor(
    @InjectRepository(ScoreEntity)
    private readonly scoreRepository: Repository<ScoreEntity>
  ){}

  async getAllScores(): Promise<ScoreEntity[] | undefined>  {
    return await this.scoreRepository.find();
  }

  async getScoreById(id: string){
    return this.scoreRepository.findOne({ where: { id } });
  }
  async getScoreByName(gameName: string) {
    return this.scoreRepository.findOne({ where: { gameName } });
  }
  async createScore(scoreData: ScoreDto): Promise<ScoreEntity | undefined> {
    const score =  plainToClass(ScoreEntity, scoreData); 
    return await this.scoreRepository.save(score);
  }

  async updateScore(id: string, scoreData: Partial<ScoreDto>): Promise<ScoreEntity | undefined> {
    const score = await this.scoreRepository.findOne({ where: { id } });
    if (!score) {
      return null;
    }
    Object.assign(score,scoreData)
    return this.scoreRepository.save(score);
  }

  async deleteScore(id: string): Promise<ScoreEntity | undefined> {
    const user = await this.scoreRepository.findOne({ where: { id } });
    if (!user) {
      return null;
    }
    await this.scoreRepository.remove(user);
    return user;
  }

//   async findByUserName(username: string): Promise<ScoreDto | null> {
//     return await this.scoreRepository.findOne({ where: { name: username } });
//   }
//   async findByUserEmail(email: string): Promise<ScoreDto | null> {
//     return await this.scoreRepository.findOne({ where: { email } });
//   }

//   async findByUserWallerId(walletId: string): Promise<ScoreDto | null> {
//     return await this.scoreRepository.findOne({ where: { walletId } });
//   }
}
