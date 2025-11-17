import { DataTypes, Model } from "sequelize";
import { sequelize } from "../database/db";
import { Reservation } from "./Reservation";

export interface ClientI {
  id?: number;
  first_name: string;
  last_name: string;
  document: string;
  phone: string;
  email: string;
  nationality: string;
  status: "ACTIVE" | "INACTIVE";
}

export class Client extends Model<ClientI> implements ClientI {
  public first_name!: string;
  public last_name!: string;
  public document!: string;
  public phone!: string;
  public email!: string;
  public nationality!: string;
  public status!: "ACTIVE" | "INACTIVE";
}

Client.init(
  {
    first_name: {
      type: DataTypes.STRING,
      allowNull: false
    },
    last_name: {
      type: DataTypes.STRING,
      allowNull: false
    },
    document: {
      type: DataTypes.STRING,
      allowNull: false
    },
    phone: {
      type: DataTypes.STRING,
      allowNull: true
    },
    email: {
      type: DataTypes.STRING,
      allowNull: true
    },
    nationality: {
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
    modelName: "Client",
    tableName: "clients",
    timestamps: false,
  }
);
