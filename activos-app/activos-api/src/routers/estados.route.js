import { Router } from "express";
import {
    nuevoEstado,
    getEstado,
    modificarEstado,
    bajaEstado,
    altaEstado,
    listarEstados
} from '../controllers/estados.controller.js';
import { authAdmin, authDefault, authView } from "../controllers/auth.controller.js";

const router = Router();

router.route('/').get(authView, listarEstados);
router.route('/nuevo').post(authAdmin, nuevoEstado);

router.route('/:id').get(authView, getEstado)
router.route('/:id').put(authAdmin, modificarEstado)
router.route('/:id','/:id/baja').delete(authAdmin, bajaEstado);  

router.route('/:id/alta').put(authAdmin, altaEstado);

export default router;