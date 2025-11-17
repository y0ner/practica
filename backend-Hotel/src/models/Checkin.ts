import { DataTypes, Model } from "sequelize";
import { sequelize } from "../database/db";
import { Reservation } from "./Reservation";

export interface CheckinI {
  id?: number;
  time: Date;
  observation: string;
  reservation_id: number;
  status: "ACTIVE" | "INACTIVE";
}

export class Checkin extends Model<CheckinI> implements CheckinI {
  public time!: Date;
  public observation!: string;
  public reservation_id!: number;
  public status!: "ACTIVE" | "INACTIVE";
}

Checkin.init(
  {
    time: {
      type: DataTypes.DATE,
      allowNull: false
    },
    observation: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    reservation_id: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    status: {
      type: DataTypes.ENUM("ACTIVE", "INACTIVE"),
      defaultValue: "ACTIVE",
    },
  },
  {
    sequelize,
    modelName: "Checkin",
    tableName: "checkins",
    timestamps: false,
  }
);


