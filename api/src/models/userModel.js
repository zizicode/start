import { pool } from "../config/database.js"
import bcrypt from "bcryptjs"

export const userModel = {
  async create(email, password, role = "author") {
    const passwordHash = await bcrypt.hash(password, 10)
    const result = await pool.query(
      "INSERT INTO users (email, password_hash, role) VALUES ($1, $2, $3) RETURNING id, email, role, created_at",
      [email, passwordHash, role],
    )
    return result.rows[0]
  },

  async findByEmail(email) {
    const result = await pool.query("SELECT * FROM users WHERE email = $1", [email])
    return result.rows[0]
  },

  async findById(id) {
    const result = await pool.query("SELECT id, email, role, created_at, updated_at FROM users WHERE id = $1", [id])
    return result.rows[0]
  },

  async getAll() {
    const result = await pool.query(
      "SELECT id, email, role, created_at, updated_at FROM users ORDER BY created_at DESC",
    )
    return result.rows
  },

  async update(id, data) {
    const fields = []
    const values = []
    let paramCount = 1

    if (data.email) {
      fields.push(`email = $${paramCount++}`)
      values.push(data.email)
    }
    if (data.password) {
      const passwordHash = await bcrypt.hash(data.password, 10)
      fields.push(`password_hash = $${paramCount++}`)
      values.push(passwordHash)
    }
    if (data.role) {
      fields.push(`role = $${paramCount++}`)
      values.push(data.role)
    }

    fields.push(`updated_at = NOW()`)
    values.push(id)

    const result = await pool.query(
      `UPDATE users SET ${fields.join(", ")} WHERE id = $${paramCount} RETURNING id, email, role, updated_at`,
      values,
    )
    return result.rows[0]
  },

  async delete(id) {
    const result = await pool.query("DELETE FROM users WHERE id = $1 RETURNING id", [id])
    return result.rows[0]
  },

  async verifyPassword(plainPassword, hashedPassword) {
    return await bcrypt.compare(plainPassword, hashedPassword)
  },
}
