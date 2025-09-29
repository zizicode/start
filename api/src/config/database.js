import pg from "pg"
import dotenv from "dotenv"

dotenv.config()

const { Pool } = pg

export const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
})

// Test connection
pool.on("connect", () => {
  console.log("✅ Connected to PostgreSQL database")
})

pool.on("error", (err) => {
  console.error("❌ Unexpected error on idle client", err)
  process.exit(-1)
})
