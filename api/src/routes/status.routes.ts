import { Router } from "express";
import { checkDatabase } from "../config/config.db";

const router = Router();

router.get("/", async (_req, res) => {
  const dbOn = await checkDatabase();
  res.json({
    server: "On",
    database: dbOn ? "On" : "Off",
  });
});

export default router;
