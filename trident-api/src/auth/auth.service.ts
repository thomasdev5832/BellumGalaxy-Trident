import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UserService } from 'src/user/user.service';
import { AuthResponseDto } from './auth.dto';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class AuthService {
    private jwtExpirationTimeInSeconds: number;

    constructor(
        private readonly userService: UserService,
        private readonly jwtService: JwtService,
        private readonly configService: ConfigService,
    ){
        this.jwtExpirationTimeInSeconds = +this.configService.get<number>('JWT_EXPIRATION_TIME'); 
    }

    async signIn(email: string, password: string): Promise<AuthResponseDto> {
        console.log(email, password)
        const foundUser = await this.userService.findByUserEmail(email);
        console.log(foundUser)
        if(!foundUser || !(password === foundUser.password)) {
            throw new UnauthorizedException();
        }

        const payload = {
            sub: foundUser.userId, 
            username: foundUser.email
        };

        const token = this.jwtService.sign(payload);

        return {
            token,
            expiresIn: this.jwtExpirationTimeInSeconds
        }
    }
}
