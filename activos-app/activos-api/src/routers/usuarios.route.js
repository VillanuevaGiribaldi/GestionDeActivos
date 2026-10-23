import { Router } from "express";
import { nuevoUsuario,modificarUsuario, bajaUsuario, altaUsuario, getUsuario, encriptar} from '../controllers/usuarios.controller.js'
import { authAdmin } from "../controllers/auth.controller.js";

const router = Router();


router.route('/nuevo').post(authAdmin, nuevoUsuario)
router.route('/test/encriptar').put(encriptar)

router.route('/:id').put(authAdmin, modificarUsuario)
router.route('/:id').get(authAdmin, getUsuario)

router.route('/:id','/:id/baja').delete(authAdmin, bajaUsuario)
router.route('/:id/alta').put(authAdmin, altaUsuario)
export default router