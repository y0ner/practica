import { DataTypes, Model } from "sequelize";
import { sequelize } from "../database/db";

export interface ReservationServiceI {
  id?: number;
  quantity: number;
  reservation_id: number;
  service_id: number;
  status: "ACTIVE" | "INACTIVE";
}

export class ReservationService extends Model<ReservationServiceI> implements ReservationServiceI {
  public quantity!: number;
  public reservation_id!: number;
  public service_id!: number;
  public status!: "ACTIVE" | "INACTIVE";
}

ReservationService.init(
  {
    quantity: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    reservation_id: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    service_id: {
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
    modelName: "ReservationService",
    tableName: "reservationservices",
    timestamps: false,
  }
);


