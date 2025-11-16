import { DataTypes, Model } from "sequelize";
import { sequelize } from "../database/db";


export interface SaleI {
  id?: number;
  sale_date: Date;
  subtotal: number;
  tax: number;
  discounts: number;
  total: number;
  client_id: number;
  status: "ACTIVE" | "INACTIVE";
}

export class Sale extends Model<SaleI> implements SaleI {
  public sale_date!: Date;
  public subtotal!: number;
  public tax!: number;
  public discounts!: number;
  public total!: number;
  public client_id!: number;
  public status!: "ACTIVE" | "INACTIVE";
}

Sale.init(
  {
    sale_date: {
      type: DataTypes.DATE,
      allowNull: true
    },
    subtotal: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    tax: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    discounts: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    total: {
      type: DataTypes.INTEGER,
      allowNull: true
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
    modelName: "Sale",
    tableName: "sales",
    timestamps: false,
  }
);


