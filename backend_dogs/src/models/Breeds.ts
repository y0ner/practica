import { DataTypes, Model } from "sequelize";
import { sequelize } from "../database/db";
import { Dogs } from "./Dogs";

export interface BreedsI {
  id?: number;
  name: string;
  status: "ACTIVE" | "INACTIVE";
}

export class Breeds extends Model<BreedsI> {
  public id!: number;
  public name!: string;
  public status!: "ACTIVE" | "INACTIVE";
}

Breeds.init(
  {
    id: { // Definición explícita de la Clave Primaria
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        notEmpty: { msg: "El nombre no puede estar vacío" },
      },
    },
    status: {
      type: DataTypes.ENUM("ACTIVE", "INACTIVE"),
      defaultValue: "ACTIVE",
    },
  },
  {
    sequelize,
    modelName: "YI_breeds",
    tableName: "YI_breeds",
    timestamps: false,
  }
);

Breeds.hasMany(Dogs, {
  foreignKey: "breeds_id",
  sourceKey: "id",
});
Dogs.belongsTo(Breeds, {
  foreignKey: "breeds_id",
  targetKey: "id",
});