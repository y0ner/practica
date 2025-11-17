import { DataTypes, Model } from "sequelize";
import { sequelize } from "../database/db";
import { Room } from "./Room";
import { Rate } from "./Rate";

export interface RoomTypeI {
  id?: number;
  name: string;
  description: string;
  max_people: number;
  includes_breakfast: boolean;
  status: "ACTIVE" | "INACTIVE";
}

export class RoomType extends Model<RoomTypeI> implements RoomTypeI {
  public name!: string;
  public description!: string;
  public max_people!: number;
  public includes_breakfast!: boolean;
  public status!: "ACTIVE" | "INACTIVE";
}

RoomType.init(
  {
    name: {
      type: DataTypes.STRING,
      allowNull: false
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    max_people: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    includes_breakfast: {
      type: DataTypes.BOOLEAN,
      allowNull: false
    },
    status: {
      type: DataTypes.ENUM("ACTIVE", "INACTIVE"),
      defaultValue: "ACTIVE",
    },
  },
  {
    sequelize,
    modelName: "RoomType",
    tableName: "roomtypes",
    timestamps: false,
  }
);
