import { mediaModel } from "../models/mediaModel.js"
import fs from "fs"
import path from "path"
import { fileURLToPath } from "url"

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

export const mediaController = {
  async upload(req, res) {
    try {
      if (!req.file) {
        return res.status(400).json({ error: "No file uploaded" })
      }

      const fileUrl = `/media/${req.file.filename}`
      const type = req.file.mimetype.startsWith("image") ? "image" : "video"

      const mediaData = {
        file_url: fileUrl,
        type,
        title: req.body.title || req.file.originalname,
        description: req.body.description || null,
        uploaded_by: req.user.id,
      }

      const media = await mediaModel.create(mediaData)
      res.status(201).json({
        message: "File uploaded successfully",
        media,
      })
    } catch (error) {
      console.error("Upload error:", error)
      res.status(500).json({ error: "Internal server error" })
    }
  },

  async getAll(req, res) {
    try {
      const filters = {}
      if (req.query.type) {
        filters.type = req.query.type
      }
      if (req.query.uploaded_by) {
        filters.uploaded_by = req.query.uploaded_by
      }

      const media = await mediaModel.getAll(filters)
      res.json(media)
    } catch (error) {
      console.error("Get all media error:", error)
      res.status(500).json({ error: "Internal server error" })
    }
  },

  async getById(req, res) {
    try {
      const media = await mediaModel.findById(req.params.id)
      if (!media) {
        return res.status(404).json({ error: "Media not found" })
      }
      res.json(media)
    } catch (error) {
      console.error("Get media error:", error)
      res.status(500).json({ error: "Internal server error" })
    }
  },

  async update(req, res) {
    try {
      const media = await mediaModel.update(req.params.id, req.body)
      if (!media) {
        return res.status(404).json({ error: "Media not found" })
      }
      res.json({ message: "Media updated successfully", media })
    } catch (error) {
      console.error("Update media error:", error)
      res.status(500).json({ error: "Internal server error" })
    }
  },

  async delete(req, res) {
    try {
      const media = await mediaModel.delete(req.params.id)
      if (!media) {
        return res.status(404).json({ error: "Media not found" })
      }

      // Delete physical file
      const filePath = path.join(__dirname, "../../", media.file_url)
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath)
      }

      res.json({ message: "Media deleted successfully" })
    } catch (error) {
      console.error("Delete media error:", error)
      res.status(500).json({ error: "Internal server error" })
    }
  },
}
