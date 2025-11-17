import { DataTypes, Model } from "sequelize";
import { sequelize } from "../database/db";

export interface CheckoutI {
  id?: number;
  time: Date;
  observation: string;
  status: "ACTIVE" | "INACTIVE";
}

export class Checkout extends Model<CheckoutI> implements CheckoutI {
  public time!: Date;
  public observation!: string;
  public status!: "ACTIVE" | "INACTIVE";
}

Checkout.init(
  {
    time: {
      type: DataTypes.DATE,
      allowNull: false
    },
    observation: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    status: {
      type: DataTypes.ENUM("ACTIVE", "INACTIVE"),
      defaultValue: "ACTIVE",
    },
  },
  {
    sequelize,
    modelName: "Checkout",
    tableName: "checkouts",
    timestamps: false,
  }
);


