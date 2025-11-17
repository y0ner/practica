import { DataTypes, Model } from "sequelize";
import { sequelize } from "../database/db";
import { Client } from "./Client";
import { Checkin } from "./Checkin";

export interface ReservationI {
  id?: number;
  quantity: number;
  client_id: number;
  status: "ACTIVE" | "INACTIVE";
}

export class Reservation extends Model<ReservationI> implements ReservationI {
  public quantity!: number;
  public client_id!: number;
  public status!: "ACTIVE" | "INACTIVE";
}

Reservation.init(
  {
    quantity: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    client_id: {
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
    modelName: "Reservation",
    tableName: "reservations",
    timestamps: false,
  }
);

Reservation.hasMany(Checkin, {
  foreignKey: "reservation_id",
  sourceKey: "id",
});
Checkin.belongsTo(Reservation, {
  foreignKey: "reservation_id",
  targetKey: "id",
});


