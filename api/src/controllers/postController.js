import { postModel } from "../models/postModel.js"

export const postController = {
  async create(req, res) {
    try {
      const postData = {
        ...req.body,
        author_id: req.user.id,
      }

      const post = await postModel.create(postData)
      res.status(201).json({ message: "Post created successfully", post })
    } catch (error) {
      console.error("Create post error:", error)
      if (error.code === "23505") {
        // Unique violation
        return res.status(409).json({ error: "Slug already exists" })
      }
      res.status(500).json({ error: "Internal server error" })
    }
  },

  async getAll(req, res) {
    try {
      const filters = {}
      if (req.query.published !== undefined) {
        filters.published = req.query.published === "true"
      }
      if (req.query.author_id) {
        filters.author_id = req.query.author_id
      }

      const posts = await postModel.getAll(filters)
      res.json(posts)
    } catch (error) {
      console.error("Get all posts error:", error)
      res.status(500).json({ error: "Internal server error" })
    }
  },

  async getById(req, res) {
    try {
      const post = await postModel.findById(req.params.id)
      if (!post) {
        return res.status(404).json({ error: "Post not found" })
      }

      // Increment views
      await postModel.incrementViews(req.params.id)

      res.json(post)
    } catch (error) {
      console.error("Get post error:", error)
      res.status(500).json({ error: "Internal server error" })
    }
  },

  async getBySlug(req, res) {
    try {
      const post = await postModel.findBySlug(req.params.slug)
      if (!post) {
        return res.status(404).json({ error: "Post not found" })
      }

      // Increment views
      await postModel.incrementViews(post.id)

      res.json(post)
    } catch (error) {
      console.error("Get post by slug error:", error)
      res.status(500).json({ error: "Internal server error" })
    }
  },

  async update(req, res) {
    try {
      const post = await postModel.update(req.params.id, req.body)
      if (!post) {
        return res.status(404).json({ error: "Post not found" })
      }
      res.json({ message: "Post updated successfully", post })
    } catch (error) {
      console.error("Update post error:", error)
      if (error.code === "23505") {
        return res.status(409).json({ error: "Slug already exists" })
      }
      res.status(500).json({ error: "Internal server error" })
    }
  },

  async delete(req, res) {
    try {
      const post = await postModel.delete(req.params.id)
      if (!post) {
        return res.status(404).json({ error: "Post not found" })
      }
      res.json({ message: "Post deleted successfully" })
    } catch (error) {
      console.error("Delete post error:", error)
      res.status(500).json({ error: "Internal server error" })
    }
  },
}
