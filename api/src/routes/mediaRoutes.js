import express from "express"
import { mediaController } from "../controllers/mediaController.js"
import { authenticateToken } from "../middleware/auth.js"
import { upload } from "../middleware/upload.js"

const router = express.Router()

// Public routes
router.get("/", mediaController.getAll)
router.get("/:id", mediaController.getById)

// Protected routes (require authentication)
router.post("/", authenticateToken, upload.single("file"), mediaController.upload)
router.put("/:id", authenticateToken, mediaController.update)
router.delete("/:id", authenticateToken, mediaController.delete)

export default router
