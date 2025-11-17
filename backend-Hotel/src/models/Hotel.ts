import { DataTypes, Model } from "sequelize";
import { sequelize } from "../database/db";
import { Room } from "./Room";

export interface HotelI {
  id?: number;
  name: string;
  address: string;
  city: string;
  country: string;
  phone: string;
  stars: number;
  status: "ACTIVE" | "INACTIVE";
}

export class Hotel extends Model<HotelI> implements HotelI {
  public name!: string;
  public address!: string;
  public city!: string;
  public country!: string;
  public phone!: string;
  public stars!: number;
  public status!: "ACTIVE" | "INACTIVE";
}

Hotel.init(
  {
    name: {
      type: DataTypes.STRING,
      allowNull: false
    },
    address: {
      type: DataTypes.STRING,
      allowNull: false
    },
    city: {
      type: DataTypes.STRING,
      allowNull: false
    },
    country: {
      type: DataTypes.STRING,
      allowNull: false
    },
    phone: {
      type: DataTypes.STRING,
      allowNull: true
    },
    stars: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    status: {
      type: DataTypes.ENUM("ACTIVE", "INACTIVE"),
      defaultValue: "ACTIVE",
    },
  },
  {
    sequelize,
    modelName: "Hotel",
    tableName: "hotels",
    timestamps: false,
  }
);
