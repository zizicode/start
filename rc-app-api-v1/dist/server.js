"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const pg_1 = require("pg");
const origin_config_1 = require("./config/origin.config");
const dot_config_1 = __importDefault(require("./config/dot.config"));
const morgan_1 = __importDefault(require("morgan"));
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const app = (0, express_1.default)();
const PORT = dot_config_1.default.PORT;
// Middlewares
if (dot_config_1.default.NODE_ENV === 'production') {
    const accessLogStream = fs_1.default.createWriteStream(path_1.default.join(__dirname, "access.log"), { flags: "a" });
    app.use((0, morgan_1.default)("combined", { stream: accessLogStream }));
}
else {
    app.use((0, morgan_1.default)('dev'));
}
app.use((0, cors_1.default)({
    origin: (origin, callback) => {
        // Permitir solicitudes sin origin (ej: Postman, backend)
        if (!origin)
            return callback(null, true);
        if (origin_config_1.allowedOrigins.includes(origin)) {
            callback(null, true);
        }
        else {
            callback(new Error("No permitido por CORS"));
        }
    },
}));
app.use(express_1.default.json());
// Conexión a PostgreSQL
const pool = new pg_1.Pool({
    host: dot_config_1.default.PG_URL,
    port: dot_config_1.default.PG_PORT,
    user: dot_config_1.default.PG_USER,
    password: dot_config_1.default.PG_PASS,
    database: dot_config_1.default.PG_DATABASE,
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
    }
    catch (error) {
        dbStatus = false;
    }
    res.json({
        host: !!dot_config_1.default.HOST,
        entorno: dot_config_1.default.NODE_ENV,
        database: dbStatus,
    });
});
// Iniciar servidor
app.listen(PORT, () => {
    console.log(`Servidor escuchando en http://${dot_config_1.default.HOST}:${PORT}`);
});
