import { IsNumber, IsEmail, IsOptional, IsString, MaxLength, MinLength } from "class-validator";

export class ScoreDto {
    @IsString()
    id: string;

    @IsString()
    @MinLength(1)
    @MaxLength(255)
    gameName: string;

    @IsNumber()
    score: string;

    @IsString()
    data: string;
}
