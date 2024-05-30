import * as express from 'express';

declare global {
  namespace Express {
    interface Request {
      user?: any; // Assumindo que 'User' é a interface ou tipo do seu usuário
    }
  }
}