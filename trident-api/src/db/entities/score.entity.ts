import { Entity, PrimaryGeneratedColumn, Column } from "typeorm";


@Entity({ name: 'score' })
export class ScoreEntity {
    @PrimaryGeneratedColumn()
    id: string;

    @Column({ type: 'varchar', length: 255, nullable: false })
    gameName: string;

    @Column({ type: 'int', nullable: false })
    score: number;

    @Column({ type: 'text', nullable: false })
    data: string;

}
