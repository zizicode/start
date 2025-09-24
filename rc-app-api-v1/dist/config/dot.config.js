"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
// doc.config.ts
const dotenv_1 = __importDefault(require("dotenv"));
const path_1 = __importDefault(require("path"));
// Determinar el entorno
const env = process.env.NODE_ENV || 'development';
// Cargar el .env correspondiente
dotenv_1.default.config({
    path: path_1.default.resolve(__dirname, `.env.${env}`),
});
// Configuración exportada
const config = {
    NODE_ENV: process.env.NODE_ENV || 'development',
    PORT: Number(process.env.PORT) || 3030,
    HOST: process.env.HOST || 'localhost',
    PG_URL: process.env.PG_URL || 'localhost',
    PG_USER: process.env.PG_USER || 'rctv',
    PG_PORT: Number(process.env.PG_PORT) || 5432,
    PG_DATABASE: process.env.PG_DATABASE || 'rctv',
    PG_PASS: process.env.PG_PASS || 'password',
};
exports.default = config;
