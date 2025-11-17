import { Sequelize } from "sequelize";
import dotenv from "dotenv";
import oracledb from "oracledb";
import tedious from "tedious"; 

dotenv.config();

interface DatabaseConfig {
  dialect: string;
  host: string;
  username: string;
  password: string;
  database: string;
  port: number;
  dialectModule?: any;
  dialectOptions?: any;
}

const dbConfigurations: Record<string, DatabaseConfig> = {
  mysql: {
    dialect: "mysql",
    host: process.env.MYSQL_HOST || "localhost",
    username: process.env.MYSQL_USER || "root",
    password: process.env.MYSQL_PASSWORD || "",
    database: process.env.MYSQL_NAME || "test",
    port: parseInt(process.env.MYSQL_PORT || "3306"),
  },
  postgres: {
    dialect: "postgres",
    host: process.env.POSTGRES_HOST || "localhost",
    username: process.env.POSTGRES_USER || "postgres",
    password: process.env.POSTGRES_PASSWORD || "",
    database: process.env.POSTGRES_NAME || "test",
    port: parseInt(process.env.POSTGRES_PORT || "5432"),
  },
  oracle: {
    dialect: "oracle",
    host: process.env.ORACLE_HOST || "localhost",
    username: process.env.ORACLE_USER || "system",
    password: process.env.ORACLE_PASSWORD || "",
    database: process.env.ORACLE_NAME || "XE",
    port: parseInt(process.env.ORACLE_PORT || "1521"),
    dialectModule: oracledb,
    dialectOptions: {
      connectString: `${process.env.ORACLE_HOST || "localhost"}:${
        process.env.ORACLE_PORT || "1521"
      }/${process.env.ORACLE_NAME || "XE"}`,
    },
  },
  mssql: {
    dialect: "mssql",
    host: process.env.MSSQL_HOST || "localhost",
    username: process.env.MSSQL_USER || "sa",
    password: process.env.MSSQL_PASSWORD || "",
    database: process.env.MSSQL_NAME || "test",
    port: parseInt(process.env.MSSQL_PORT || "1433"),
    dialectModule: tedious, // 
    dialectOptions: {
      options: {
        encrypt: false, 
        trustServerCertificate: true,
      },
    },
  },
};

const selectedEngine = process.env.DB_ENGINE || "mysql";
const selectedConfig = dbConfigurations[selectedEngine];

if (!selectedConfig) {
  throw new Error(`Motor de base de datos no soportado: ${selectedEngine}`);
}

console.log(`🔌 Conectando a base de datos: ${selectedEngine.toUpperCase()}`);

export const sequelize = new Sequelize(
  selectedConfig.database,
  selectedConfig.username,
  selectedConfig.password,
  {
    host: selectedConfig.host,
    port: selectedConfig.port,
    dialect: selectedConfig.dialect as any,
    dialectModule: selectedConfig.dialectModule,
    dialectOptions: selectedConfig.dialectOptions,
    logging: process.env.NODE_ENV === "development" ? console.log : false,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000,
    },
  }
);

export const getDatabaseInfo = () => {
  return {
    engine: selectedEngine,
    config: selectedConfig,
    connectionString: `${selectedConfig.dialect}://${selectedConfig.username}@${selectedConfig.host}:${selectedConfig.port}/${selectedConfig.database}`,
  };
};

export const testConnection = async (): Promise<boolean> => {
  try {
    await sequelize.authenticate();
    console.log(`✅ Conexión exitosa a ${selectedEngine.toUpperCase()}`);
    return true;
  } catch (error) {
    console.error(`❌ Error de conexión a ${selectedEngine.toUpperCase()}:`, error);
    return false;
  }
};
