import { pool } from "../config/database.js"

export const postModel = {
  async create(data) {
    const { title, slug, body, cover_url, author_id, published = false } = data
    const result = await pool.query(
      `INSERT INTO posts (title, slug, body, cover_url, author_id, published) 
       VALUES ($1, $2, $3, $4, $5, $6) 
       RETURNING *`,
      [title, slug, body, cover_url, author_id, published],
    )
    return result.rows[0]
  },

  async findById(id) {
    const result = await pool.query(
      `SELECT p.*, u.email as author_email 
       FROM posts p 
       LEFT JOIN users u ON p.author_id = u.id 
       WHERE p.id = $1`,
      [id],
    )
    return result.rows[0]
  },

  async findBySlug(slug) {
    const result = await pool.query(
      `SELECT p.*, u.email as author_email 
       FROM posts p 
       LEFT JOIN users u ON p.author_id = u.id 
       WHERE p.slug = $1`,
      [slug],
    )
    return result.rows[0]
  },

  async getAll(filters = {}) {
    let query = `
      SELECT p.*, u.email as author_email 
      FROM posts p 
      LEFT JOIN users u ON p.author_id = u.id
    `
    const conditions = []
    const values = []

    if (filters.published !== undefined) {
      conditions.push(`p.published = $${conditions.length + 1}`)
      values.push(filters.published)
    }

    if (filters.author_id) {
      conditions.push(`p.author_id = $${conditions.length + 1}`)
      values.push(filters.author_id)
    }

    if (conditions.length > 0) {
      query += " WHERE " + conditions.join(" AND ")
    }

    query += " ORDER BY p.created_at DESC"

    const result = await pool.query(query, values)
    return result.rows
  },

  async update(id, data) {
    const fields = []
    const values = []
    let paramCount = 1

    const allowedFields = ["title", "slug", "body", "cover_url", "published"]

    allowedFields.forEach((field) => {
      if (data[field] !== undefined) {
        fields.push(`${field} = $${paramCount++}`)
        values.push(data[field])
      }
    })

    fields.push(`updated_at = NOW()`)
    values.push(id)

    const result = await pool.query(
      `UPDATE posts SET ${fields.join(", ")} WHERE id = $${paramCount} RETURNING *`,
      values,
    )
    return result.rows[0]
  },

  async incrementViews(id) {
    const result = await pool.query("UPDATE posts SET views = views + 1 WHERE id = $1 RETURNING views", [id])
    return result.rows[0]
  },

  async delete(id) {
    const result = await pool.query("DELETE FROM posts WHERE id = $1 RETURNING id", [id])
    return result.rows[0]
  },
}
