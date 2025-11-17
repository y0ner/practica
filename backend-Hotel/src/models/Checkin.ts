import { DataTypes, Model } from "sequelize";
import { sequelize } from "../database/db";
import { Reservation } from "./Reservation";

export interface CheckinI {
  id?: number;
  time: Date;
  observation?: string;
  reservation_id: number;
}

export class Checkin extends Model<CheckinI> implements CheckinI {
  public time!: Date;
  public observation?: string;
  public reservation_id!: number;
}

Checkin.init(
  {
    time: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    observation: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    reservation_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    }
  },
  {
    sequelize,
    modelName: "Checkin",
    tableName: "checkins",
    timestamps: false,
  }
);
