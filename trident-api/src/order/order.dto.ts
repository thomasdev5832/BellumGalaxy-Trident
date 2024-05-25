import { IsBoolean, IsNumber, IsOptional, IsString, MaxLength, MinLength } from "class-validator";
import { Type } from 'class-transformer';


export class OrderDto {
  @IsString()
  id?: string;

  @IsString()
  @IsOptional()
  @Type(() => Date)
  created_at?: Date;

  @IsString()
  @MinLength(1)
  @MaxLength(255)
  userId?: string;

  @IsString()
  @MinLength(1)
  @MaxLength(255)
  gameId?: string;

  @IsString()
  @MinLength(1)
  @MaxLength(255)
  gameAddress: string;

  @IsString()
  @MinLength(1)
  @MaxLength(255)
  previousOwner: string;

  @IsString()
  @MinLength(1)
  @MaxLength(255)
  receiver: string;

  @IsNumber()
  nftId: number;

  @IsString()
  @MinLength(1)
  @MaxLength(255)
  gameName?: string;

  @IsString()
  @MinLength(1)
  @MaxLength(255)
  gameSymbol?: string;


  @IsBoolean()
  isBlocked?: boolean;
}
