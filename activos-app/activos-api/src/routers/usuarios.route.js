import { Router } from "express";
import {loginUsuario} from '../controllers/usuarios.controller.js'


const router = Router();

router.route('/login').post(loginUsuario)

export default router