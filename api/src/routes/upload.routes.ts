import { Router } from "express";
import multer from "multer";
import path from "path";

const router = Router();

// Configuración de multer (sube a /uploads)
const storage = multer.diskStorage({
  destination: "uploads/",
  filename: (_req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});

const upload = multer({ storage });

// Endpoint para subir imagen
router.post("/", upload.single("file"), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: "No file uploaded" });
  }

  res.json({
    message: "File uploaded successfully",
    fileUrl: `/media/${req.file.filename}`
  });
});

export default router;
