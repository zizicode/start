import jwt from "jsonwebtoken"
import { userModel } from "../models/userModel.js"

export const authController = {
  async register(req, res) {
    try {
      const { email, password, role } = req.body

      if (!email || !password) {
        return res.status(400).json({ error: "Email and password are required" })
      }

      const existingUser = await userModel.findByEmail(email)
      if (existingUser) {
        return res.status(409).json({ error: "User already exists" })
      }

      const user = await userModel.create(email, password, role)

      const token = jwt.sign({ id: user.id, email: user.email, role: user.role }, process.env.JWT_SECRET, {
        expiresIn: process.env.JWT_EXPIRES_IN,
      })

      res.status(201).json({
        message: "User registered successfully",
        user,
        token,
      })
    } catch (error) {
      console.error("Register error:", error)
      res.status(500).json({ error: "Internal server error" })
    }
  },

  async login(req, res) {
    try {
      const { email, password } = req.body

      if (!email || !password) {
        return res.status(400).json({ error: "Email and password are required" })
      }

      const user = await userModel.findByEmail(email)
      if (!user) {
        return res.status(401).json({ error: "Invalid credentials" })
      }

      const isValidPassword = await userModel.verifyPassword(password, user.password_hash)
      if (!isValidPassword) {
        return res.status(401).json({ error: "Invalid credentials" })
      }

      const token = jwt.sign({ id: user.id, email: user.email, role: user.role }, process.env.JWT_SECRET, {
        expiresIn: process.env.JWT_EXPIRES_IN,
      })

      res.json({
        message: "Login successful",
        user: {
          id: user.id,
          email: user.email,
          role: user.role,
        },
        token,
      })
    } catch (error) {
      console.error("Login error:", error)
      res.status(500).json({ error: "Internal server error" })
    }
  },

  async getProfile(req, res) {
    try {
      const user = await userModel.findById(req.user.id)
      if (!user) {
        return res.status(404).json({ error: "User not found" })
      }
      res.json(user)
    } catch (error) {
      console.error("Get profile error:", error)
      res.status(500).json({ error: "Internal server error" })
    }
  },
}
