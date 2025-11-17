import { DataTypes, Model } from "sequelize";
import { sequelize } from "../database/db";
import { Reservation } from "./Reservation";

export interface ServiceI {
  id?: number;
  name: string;
  description: string;
  price: number;
  category: string;
  status: "ACTIVE" | "INACTIVE";
}

export class Service extends Model<ServiceI> implements ServiceI {
  public name!: string;
  public description!: string;
  public price!: number;
  public category!: string;
  public status!: "ACTIVE" | "INACTIVE";
}

Service.init(
  {
    name: {
      type: DataTypes.STRING,
      allowNull: false
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    price: {
      type: DataTypes.FLOAT,
      allowNull: false
    },
    category: {
      type: DataTypes.STRING,
      allowNull: true
    },
    status: {
      type: DataTypes.ENUM("ACTIVE", "INACTIVE"),
      defaultValue: "ACTIVE",
    },
  },
  {
    sequelize,
    modelName: "Service",
    tableName: "services",
    timestamps: false,
  }
);
