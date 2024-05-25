import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards, HttpException, HttpStatus } from '@nestjs/common';

import { AuthGuard } from 'src/auth/auth.guard';
import { ScoreDto } from './score.dto';
import { ScoreService } from './score.service';


@Controller('score')
export class ScoreController {
  constructor(private readonly storeService: ScoreService) {}

  @Get()
  getAllUsers() {
    return this.storeService.getAllScores();
  }

  @Get(':id')
  getUserById(@Param('id') id: string) {
    return this.storeService.getScoreById(id);
  }

  @Get('/name/:name')
  getUserByName(@Param('name') name: string) {
    return this.storeService.getScoreByName(name);
  }

  @Post()
  createScore(@Body() storeData: ScoreDto) {

   
      return this.storeService.createScore(storeData);

  }

  @Put(':id')
  updateUser(@Param('id') id: string, @Body() storeData: any) {
    return this.storeService.updateScore(id, storeData);
  }

  @Delete(':id')
  deleteUser(@Param('id') id: string) {
    return this.storeService.deleteScore(id);
  }
}
