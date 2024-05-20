import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from "typeorm";
import { GameEntity } from "./game.entity";

@Entity({ name: 'users' })
export class UserEntity {
    @PrimaryGeneratedColumn()
    userId: string;

    @Column({ type: 'varchar', length: 255, nullable: false })
    name: string;

    @Column({ type: 'varchar', length: 255, nullable: false })
    lastName: string;

    @Column({ type: 'varchar', length: 255, nullable: false, unique: true })
    email: string;

    @Column({ type: 'varchar', length: 255, nullable: true })
    walletId: string;

    @Column({ type: 'varchar', length: 255, nullable: false })
    password: string;

    @OneToMany(() => GameEntity, game => game.user)
    games: GameEntity[];
}
