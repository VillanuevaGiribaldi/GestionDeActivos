import { Router } from "express";
import {loginUsuario, nuevoUsuario} from '../controllers/usuarios.controller.js'


const router = Router();

router.route('/login').post(loginUsuario)
router.route('/nuevo').post(nuevoUsuario)

export default router