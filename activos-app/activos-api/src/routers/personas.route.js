import { Router } from "express";
import { nuevaPersona } from '../controllers/personas.controller.js'
import { authDefault } from "../controllers/auth.controller.js";

const router = Router();

// Protegemos la ruta para que solo empleados de TI logueados puedan crear personas
router.route('/nueva').post(authDefault, nuevaPersona);
//router.route('/:id').get(authDefault, nuevaPersona);

export default router;