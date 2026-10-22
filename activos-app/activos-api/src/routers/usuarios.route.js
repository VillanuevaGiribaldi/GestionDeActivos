import { Router } from "express";
import { nuevoUsuario,modificarUsuario, bajaUsuario, encriptar} from '../controllers/usuarios.controller.js'
import { authAdmin } from "../controllers/auth.controller.js";

const router = Router();

//router.route('/login').post(loginUsuario)
router.route('/nuevo').post(authAdmin, nuevoUsuario)
router.route('/test/encriptar').put(encriptar)
//router.route('/:id').get()
router.route('/:id').put(authAdmin, modificarUsuario)

router.route('/:id').delete(authAdmin, bajaUsuario)

export default router