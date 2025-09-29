import express from "express"
import { postController } from "../controllers/postController.js"
import { authenticateToken } from "../middleware/auth.js"

const router = express.Router()

// Public routes
router.get("/", postController.getAll)
router.get("/:id", postController.getById)
router.get("/slug/:slug", postController.getBySlug)

// Protected routes (require authentication)
router.post("/", authenticateToken, postController.create)
router.put("/:id", authenticateToken, postController.update)
router.delete("/:id", authenticateToken, postController.delete)

export default router
