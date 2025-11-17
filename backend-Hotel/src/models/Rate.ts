import { DataTypes, Model } from "sequelize";
import { sequelize } from "../database/db";
import { Season } from "./Season";
import { RoomType } from "./RoomType";

export interface RateI {
  id?: number;
  amount: number;
  currency: string;
  description: string;
  refundable: boolean;
  season_id: number;
  roomtype_id: number;
  status: "ACTIVE" | "INACTIVE";
}

export class Rate extends Model<RateI> implements RateI {
  public amount!: number;
  public currency!: string;
  public description!: string;
  public refundable!: boolean;
  public season_id!: number;
  public roomtype_id!: number;
  public status!: "ACTIVE" | "INACTIVE";
}

Rate.init(
  {
    amount: {
      type: DataTypes.FLOAT,
      allowNull: false
    },
    currency: {
      type: DataTypes.STRING,
      allowNull: false
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    refundable: {
      type: DataTypes.BOOLEAN,
      allowNull: false
    },
    season_id: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    roomtype_id: {
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
    modelName: "Rate",
    tableName: "rates",
    timestamps: false,
  }
);


