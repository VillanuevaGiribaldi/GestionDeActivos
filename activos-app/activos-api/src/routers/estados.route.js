import { Router } from "express";
import {
    nuevoEstado,
    getEstado,
    modificarEstado,
    bajaEstado,
    altaEstado,
    listarEstados
} from '../controllers/estados.controller.js';
import { authDefault } from "../controllers/auth.controller.js";

const router = Router();

router.route('/').get(authDefault, listarEstados);
router.route('/nuevo').post(authDefault, nuevoEstado);

router.route('/:id').get(authDefault, getEstado)
router.route('/:id').put(authDefault, modificarEstado)
router.route('/:id','/:id/baja').delete(authDefault, bajaEstado);  

router.route('/:id/alta').put(authDefault, altaEstado);

export default router;