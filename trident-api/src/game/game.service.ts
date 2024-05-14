import { Injectable } from '@nestjs/common';

@Injectable()
export class GameService {
  private games = [
    { id: '1', title: 'The Witcher 3: Wild Hunt', price: 49.99 },
    { id: '2', title: 'Red Dead Redemption 2', price: 59.99 },
    { id: '3', title: 'The Legend of Zelda: Breath of the Wild', price: 59.99 },
    { id: '4', title: 'Cyberpunk 2077', price: 69.99 }
  ];

  getAllGames() {
    return this.games;
  }

  getGameById(id: string) {
    return this.games.find(game => game.id === id); 
  }

  createGame(gameData: any) {
    const newGame = { ...gameData, id: (this.games.length + 1).toString() }; 
    return newGame; 
  }

  updateGame(id: string, gameData: any) {
    const index = this.games.findIndex(game => game.id === id); 
    if (index === -1) {
      return null;
    }
    this.games[index] = { ...this.games[index], ...gameData };
    return this.games[index];
  }

  deleteGame(id: string) {
    const index = this.games.findIndex(game => game.id === id); 
    if (index === -1) {
      return null;
    }
    const deletedGame = this.games[index];
    this.games.splice(index, 1); 
    return deletedGame; 
  }
}
