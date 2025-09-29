import express from "express"
import cors from "cors"
import morgan from "morgan"
import dotenv from "dotenv"
import path from "path"
import { fileURLToPath } from "url"

// Import routes
import authRoutes from "./routes/authRoutes.js"
import userRoutes from "./routes/userRoutes.js"
import postRoutes from "./routes/postRoutes.js"
import mediaRoutes from "./routes/mediaRoutes.js"

// Import database config to test connection
import { pool } from "./config/database.js"

dotenv.config()

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const app = express()
const PORT = process.env.PORT || 3000

// Middleware
app.use(cors())
app.use(morgan("dev"))
app.use(express.json())
app.use(express.urlencoded({ extended: true }))

// Serve static files from media folder (PUBLIC ACCESS)
app.use("/media", express.static(path.join(__dirname, "../media")))

// Routes
app.use("/api/auth", authRoutes)
app.use("/api/users", userRoutes)
app.use("/api/posts", postRoutes)
app.use("/api/media", mediaRoutes)

// Health check
app.get("/api/health", (req, res) => {
  res.json({
    status: "OK",
    message: "Blog API is running",
    timestamp: new Date().toISOString(),
  })
})

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: "Route not found" })
})

// Error handler
app.use((err, req, res, next) => {
  console.error("Error:", err)
  res.status(err.status || 500).json({
    error: err.message || "Internal server error",
  })
})

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`)
  console.log(`📁 Media files served at http://localhost:${PORT}/media`)
})

// Graceful shutdown
process.on("SIGTERM", () => {
  console.log("SIGTERM signal received: closing HTTP server")
  pool.end(() => {
    console.log("Database pool closed")
  })
})
