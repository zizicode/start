import express from "express";
import statusRouter from "./routes/status.routes";
import uploadRouter from "./routes/upload.routes";

export const app = express();

app.use(express.json());

// Rutas
app.use("/status", statusRouter);
app.use("/upload", uploadRouter);

// Servir archivos estáticos desde /uploads
app.use("/media", express.static("uploads"));

app.listen(3000, () => {
  console.log("API running on port 3000");
});
