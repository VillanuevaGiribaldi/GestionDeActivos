import { Router } from "express";
import { altaPersona, bajaPersona, getPersona, listarPersonas, modificarPersona, nuevaPersona } from '../controllers/personas.controller.js'
import { authDefault } from "../controllers/auth.controller.js";

const router = Router();

// AGREGAMOS LA RUTA PARA LISTAR TODOS:
router.route('/').get(authDefault, listarPersonas);

// Protegemos la ruta para que solo empleados de TI logueados puedan crear personas
router.route('/nueva').post(authDefault, nuevaPersona);
router.route('/:id').get(authDefault, getPersona);
router.route('/:id','/:id/baja').delete(authDefault, bajaPersona)
router.route('/:id/alta').put(authDefault, altaPersona)
router.route('/:id').put(authDefault, modificarPersona)

export default router;