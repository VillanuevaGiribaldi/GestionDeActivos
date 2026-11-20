// src/routers/historial.route.js
import { Router } from "express";
import { listarHistorial, listarHistorialActivo } from '../controllers/historial.controller.js';
import { authView } from "../controllers/auth.controller.js";


const router = Router();

router.route('/').get(authView, listarHistorial);
router.route('/activo/:id').get(authView, listarHistorialActivo);

export default router;