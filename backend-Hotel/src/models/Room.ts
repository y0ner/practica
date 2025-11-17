import { DataTypes, Model } from "sequelize";
import { sequelize } from "../database/db";
import { RoomType } from "./RoomType";
import { Reservation } from "./Reservation";
import { Hotel } from "./Hotel";

export interface RoomI {
  id?: number;
  number: number;
  floor: number;
  capacity: number;
  description: string;
  base_price: number;
  available: boolean;
  roomtype_id: number;
  hotel_id: number;
  status: "ACTIVE" | "INACTIVE";
}

export class Room extends Model<RoomI> implements RoomI {
  public number!: number;
  public floor!: number;
  public capacity!: number;
  public description!: string;
  public base_price!: number;
  public available!: boolean;
  public roomtype_id!: number;
  public hotel_id!: number;
  public status!: "ACTIVE" | "INACTIVE";
}

Room.init(
  {
    number: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    floor: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    capacity: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    base_price: {
      type: DataTypes.FLOAT,
      allowNull: false
    },
    available: {
      type: DataTypes.BOOLEAN,
      allowNull: false
    },
    roomtype_id: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    hotel_id: {
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
    modelName: "Room",
    tableName: "rooms",
    timestamps: false,
  }
);
