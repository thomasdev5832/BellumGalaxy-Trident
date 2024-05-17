import { IsBoolean, IsDateString, IsNumber, IsOptional, IsString, MaxLength, MinLength, IsUrl } from "class-validator";

export class GameDto {
  @IsNumber()
  gameId: number;

  @IsNumber()
  userId: number;

  @IsString()
  @MinLength(1)
  @MaxLength(255)
  name: string;

  @IsDateString()
  released: string;

  @IsString()
  @IsOptional()
  timeLimit?: string;

  @IsString()
  @MinLength(1)
  @MaxLength(255)
  processName: string;

  @IsString()
  @MinLength(1)
  @MaxLength(255)
  developerCompany: string;

  @IsString()
  @IsOptional()
  timePlayed?: string;

  @IsBoolean()
  isBlocked: boolean;

  @IsUrl()
  @IsOptional()
  @MaxLength(255)
  gameImageUrl?: string;
}
