// doc.config.ts
import dotenv from 'dotenv';
import path from 'path';

// Determinar el entorno
const env = process.env.NODE_ENV || 'development';

// Cargar el .env correspondiente
dotenv.config({
  path: path.resolve(__dirname, `.env.${env}`),
});

// Tipado de las variables
interface EnvConfig {
  NODE_ENV: 'development' | 'production' | 'test';
  PORT: number;
  HOST: string;

  PG_URL: string;
  PG_USER: string;
  PG_PORT: number;
  PG_DATABASE: string;
  PG_PASS: string;
}

// Configuración exportada
const config: EnvConfig = {
  NODE_ENV: process.env.NODE_ENV as EnvConfig['NODE_ENV'] || 'development',
  PORT: Number(process.env.PORT) || 3030,
  HOST: process.env.HOST || 'localhost',
  PG_URL: process.env.PG_URL || 'localhost',
  PG_USER: process.env.PG_USER || 'rctv',
  PG_PORT: Number(process.env.PG_PORT) || 5432,
  PG_DATABASE: process.env.PG_DATABASE || 'rctv',
  PG_PASS: process.env.PG_PASS || 'password',
};

export default config;
