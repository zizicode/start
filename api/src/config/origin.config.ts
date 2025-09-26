import cors from "cors";
import config from "../config/dot.config";

export const allowedOrigins = [`http://localhost:${config.PORT}`, "https://rodolfocordones.com"];