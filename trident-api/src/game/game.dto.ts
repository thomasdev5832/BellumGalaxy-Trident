import { IsNumber, IsString, IsUUID, MaxLength, MinLength } from "class-validator";

export class GameDto {
  id: string;

  @IsString()
  @MinLength(5)
  @MaxLength(256)
  title: string;

  price: number;
}