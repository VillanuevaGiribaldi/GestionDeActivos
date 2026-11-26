import { Router } from "express";
import { altaPersona, bajaPersona, getPersona, listarPersonas, modificarPersona, nuevaPersona } from '../controllers/personas.controller.js'
import { authAdmin, authDefault, authView } from "../controllers/auth.controller.js";
import { getPersonaDeUsuario } from "../controllers/usuarios.controller.js";
const router = Router();

// AGREGAMOS LA RUTA PARA LISTAR TODOS:
router.route('/').get(authView, listarPersonas);

// Protegemos la ruta para que solo empleados de TI logueados puedan crear personas
router.route('/nueva').post(authAdmin, nuevaPersona);
router.route('/:id').get(authView, getPersona);
router.route('/:id','/:id/baja').delete(authAdmin, bajaPersona)
router.route('/:id/alta').put(authAdmin, altaPersona)
router.route('/:id').put(authAdmin, modificarPersona)

router.route('/:id/usuario').get(authView, getPersonaDeUsuario)


export default router;