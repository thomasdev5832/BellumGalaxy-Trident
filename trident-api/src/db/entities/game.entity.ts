import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from "typeorm";
import { UserEntity } from "./user.entity";

@Entity({ name: 'games' })
export class GameEntity {
    @PrimaryGeneratedColumn()
    gameId: number;

    @ManyToOne(() => UserEntity, user => user.games, { onDelete: 'CASCADE' })
    @JoinColumn({ name: 'userId' })
    user: UserEntity;

    @Column({ type: 'varchar', length: 255, nullable: false })
    name: string;

    @Column({ type: 'date', nullable: false })
    released: Date;

    @Column({ type: 'interval', nullable: true })
    timeLimit: string;

    @Column({ type: 'varchar', length: 255, nullable: false })
    processName: string;

    @Column({ type: 'varchar', length: 255, nullable: false })
    developerCompany: string;

    @Column({ type: 'interval', nullable: true })
    timePlayed: string;

    @Column({ type: 'boolean', default: false })
    isBlocked: boolean;

    @Column({ type: 'varchar', length: 255, nullable: true })
    gameImageUrl: string;
}
