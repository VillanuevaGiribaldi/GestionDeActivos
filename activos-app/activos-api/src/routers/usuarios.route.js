import { Router } from "express";
import { nuevoUsuario, encriptar} from '../controllers/usuarios.controller.js'
import { authAdmin } from "../controllers/auth.controller.js";

const router = Router();

//router.route('/login').post(loginUsuario)
router.route('/nuevo').post(authAdmin, nuevoUsuario)
router.route('/test/encriptar').put(encriptar)

export default router