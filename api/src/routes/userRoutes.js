import express from "express"
import { userController } from "../controllers/userController.js"
import { authenticateToken, authorizeRoles } from "../middleware/auth.js"

const router = express.Router()

// All user routes require authentication and admin role
router.use(authenticateToken)
router.use(authorizeRoles("admin"))

router.get("/", userController.getAll)
router.get("/:id", userController.getById)
router.put("/:id", userController.update)
router.delete("/:id", userController.delete)

export default router
