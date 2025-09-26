import express, { Application } from "express";
import cors from "cors";
import { Pool } from "pg";
import { allowedOrigins } from "./config/origin.config";
import config from "./config/dot.config";
import morgan from 'morgan';
import fs from 'fs';
import path from "path";


const app: Application = express();
const PORT = config.PORT;

// Middlewares
if (config.NODE_ENV === 'production') {
    const accessLogStream = fs.createWriteStream(
        path.join(__dirname, "access.log"),
        { flags: "a" }
    );
    app.use(morgan("combined", { stream: accessLogStream }));
} else {
    app.use(morgan('dev'))
}

app.use(
    cors({
        origin: (origin, callback) => {
            // Permitir solicitudes sin origin (ej: Postman, backend)
            if (!origin) return callback(null, true);

            if (allowedOrigins.includes(origin)) {
                callback(null, true);
            } else {
                callback(new Error("No permitido por CORS"));
            }
        },
    })
);

app.use(express.json());

// Conexión a PostgreSQL
const pool = new Pool({
    host: config.PG_URL,
    port: config.PG_PORT,
    user: config.PG_USER,
    password: config.PG_PASS,
    database: config.PG_DATABASE,
});

// Ruta inicial de ejemplo
app.get("/", (req, res) => {
    res.json({ message: "API funcionando 🚀" });
});

// Ruta de status
app.get("/status", async (req, res) => {
    let dbStatus = false;

    try {
        const client = await pool.connect();
        await client.query("SELECT 1"); // simple query para test
        client.release();
        dbStatus = true;
    } catch (error) {
        dbStatus = false;
    }

    res.json({
        host: !!config.HOST,
        entorno: config.NODE_ENV,
        database: dbStatus,
    });
});

// Iniciar servidor
app.listen(PORT, () => {
    console.log(`Server on http://${config.HOST}:${PORT}`);
});
