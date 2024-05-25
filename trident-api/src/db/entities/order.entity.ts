import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from "typeorm";
import { UserEntity } from "./user.entity";
import { GameEntity } from "./game.entity";

@Entity({ name: 'orders' })
export class OrderEntity {
    @PrimaryGeneratedColumn()
    id: string;

    @ManyToOne(() => UserEntity, user => user.orders, { onDelete: 'CASCADE' })
    @JoinColumn({ name: 'userId' })
    user: UserEntity;

    @ManyToOne(() => GameEntity, game => game.orders, { onDelete: 'CASCADE' })
    @JoinColumn({ name: 'gameId' })
    game: GameEntity;

    @Column({ type: 'date', nullable: false })
    created_at: Date;

    @Column({ type: 'varchar', nullable: true })
    gameAddress: string;
    
    @Column({ type: 'varchar', length: 255, nullable: false })
    previousOwner: string;

    @Column({ type: 'varchar', length: 255, nullable: false })
    receiver: string;

    @Column({ type: 'int', nullable: true })
    nftId: number;

    @Column({ type: 'bool', nullable: true, default: false })
    isBlocked: boolean;
}
