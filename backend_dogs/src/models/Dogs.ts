import { DataTypes, Model } from "sequelize";
import { sequelize } from "../database/db";

export interface DogsI {
  id?: number;
  birthday: string;
  value_dog: number;
  breeds_id: number;
  status: "ACTIVE" | "INACTIVE";
}

export class Dogs extends Model<DogsI> {
  public id!: number;
  public birthday!: string;
  public value_dog!: number;
  public breeds_id!: number;
  public status!: "ACTIVE" | "INACTIVE";
}

Dogs.init(
  {
    id: { // Definición explícita de la Clave Primaria
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    birthday: {
      type: DataTypes.TEXT,
      allowNull: false,
      validate: {
        notEmpty: { msg: "birthday no puede estar vacío" },
      },
    },
    value_dog: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
      validate: {
        notEmpty: { msg: "El Valor del perro no peuede estar vacio" },
      },
    },
    breeds_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'YI_breeds', 
        key: 'id'
      }
    },
    status: {
      type: DataTypes.ENUM("ACTIVE", "INACTIVE"),
      defaultValue: "ACTIVE",
    },
  },
  {
    sequelize,
    modelName: "YI_dogs",
    tableName: "YI_dogs",
    timestamps: false,
  }
);