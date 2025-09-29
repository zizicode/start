import { userModel } from "../models/userModel.js"

export const userController = {
  async getAll(req, res) {
    try {
      const users = await userModel.getAll()
      res.json(users)
    } catch (error) {
      console.error("Get all users error:", error)
      res.status(500).json({ error: "Internal server error" })
    }
  },

  async getById(req, res) {
    try {
      const user = await userModel.findById(req.params.id)
      if (!user) {
        return res.status(404).json({ error: "User not found" })
      }
      res.json(user)
    } catch (error) {
      console.error("Get user error:", error)
      res.status(500).json({ error: "Internal server error" })
    }
  },

  async update(req, res) {
    try {
      const user = await userModel.update(req.params.id, req.body)
      if (!user) {
        return res.status(404).json({ error: "User not found" })
      }
      res.json({ message: "User updated successfully", user })
    } catch (error) {
      console.error("Update user error:", error)
      res.status(500).json({ error: "Internal server error" })
    }
  },

  async delete(req, res) {
    try {
      const user = await userModel.delete(req.params.id)
      if (!user) {
        return res.status(404).json({ error: "User not found" })
      }
      res.json({ message: "User deleted successfully" })
    } catch (error) {
      console.error("Delete user error:", error)
      res.status(500).json({ error: "Internal server error" })
    }
  },
}
