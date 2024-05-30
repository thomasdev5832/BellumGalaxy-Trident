// auth.middleware.ts
import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { verify } from 'jsonwebtoken';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class AuthMiddleware implements NestMiddleware {
  constructor(private configService: ConfigService) {}

  use(req: Request, res: Response, next: NextFunction) {
    const token = req.headers.authorization?.split(' ')[1]; // Assume que o token está no formato 'Bearer token'

    if (!token) {
      return res.status(401).json({ message: 'Token de autorização não fornecido.' });
    }

    try {
      const decodedToken = verify(token, this.configService.get<string>('JWT_SECRET')); // Use sua chave secreta para verificar o token
      req.user = decodedToken; // Adicione os detalhes do usuário ao objeto de solicitação para uso posterior
      next();
    } catch (error) {
      return res.status(401).json({ message: 'Token de autorização inválido.' });
    }
  }
}