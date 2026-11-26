import { Router } from "express";
import {
    nuevoMantenimiento,
    getMantenimiento,
    listarMantenimientos,
    modificarMantenimiento,
    finMantenimiento,
    bajaMantenimiento,
    altaMantenimiento
} from '../controllers/mantenimientos.controller.js';
import { authDefault, authView } from "../controllers/auth.controller.js";

const router = Router();

router.route('/').get(authView, listarMantenimientos);
router.route('/nuevo').post(authDefault, nuevoMantenimiento);

router.route('/:id').get(authView, getMantenimiento);
router.route('/:id').put(authDefault, modificarMantenimiento);
router.route('/:id').delete(authDefault, bajaMantenimiento);

router.route('/:id/finalizar').put(authDefault, finMantenimiento);
router.route('/:id/alta').put(authDefault, altaMantenimiento);

export default router;