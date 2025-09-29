import { pool } from "../config/database.js"

export const mediaModel = {
  async create(data) {
    const { file_url, type, title, description, uploaded_by } = data
    const result = await pool.query(
      `INSERT INTO media (file_url, type, title, description, uploaded_by) 
       VALUES ($1, $2, $3, $4, $5) 
       RETURNING *`,
      [file_url, type, title, description, uploaded_by],
    )
    return result.rows[0]
  },

  async findById(id) {
    const result = await pool.query(
      `SELECT m.*, u.email as uploader_email 
       FROM media m 
       LEFT JOIN users u ON m.uploaded_by = u.id 
       WHERE m.id = $1`,
      [id],
    )
    return result.rows[0]
  },

  async getAll(filters = {}) {
    let query = `
      SELECT m.*, u.email as uploader_email 
      FROM media m 
      LEFT JOIN users u ON m.uploaded_by = u.id
    `
    const conditions = []
    const values = []

    if (filters.type) {
      conditions.push(`m.type = $${conditions.length + 1}`)
      values.push(filters.type)
    }

    if (filters.uploaded_by) {
      conditions.push(`m.uploaded_by = $${conditions.length + 1}`)
      values.push(filters.uploaded_by)
    }

    if (conditions.length > 0) {
      query += " WHERE " + conditions.join(" AND ")
    }

    query += " ORDER BY m.created_at DESC"

    const result = await pool.query(query, values)
    return result.rows
  },

  async update(id, data) {
    const fields = []
    const values = []
    let paramCount = 1

    const allowedFields = ["title", "description"]

    allowedFields.forEach((field) => {
      if (data[field] !== undefined) {
        fields.push(`${field} = $${paramCount++}`)
        values.push(data[field])
      }
    })

    if (fields.length === 0) {
      return null
    }

    values.push(id)

    const result = await pool.query(
      `UPDATE media SET ${fields.join(", ")} WHERE id = $${paramCount} RETURNING *`,
      values,
    )
    return result.rows[0]
  },

  async delete(id) {
    const result = await pool.query("DELETE FROM media WHERE id = $1 RETURNING *", [id])
    return result.rows[0]
  },
}
