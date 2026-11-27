import { Router } from "express";
import {
    nuevaUbicacion,
    getUbicacion,
    modificarUbicacion,
    bajaUbicacion,
    altaUbicacion,
    listarUbicaciones
} from '../controllers/ubicaciones.controller.js';
import { authAdmin, authView } from "../controllers/auth.controller.js";

const router = Router();

router.route('/').get(authView, listarUbicaciones);
router.route('/nueva').post(authAdmin, nuevaUbicacion);

router.route('/:id').get(authView, getUbicacion);
router.route('/:id').put(authAdmin, modificarUbicacion);

// Baja y alta lógica
router.route('/:id').delete(authAdmin, bajaUbicacion);
router.route('/:id/baja','/:id').delete(authAdmin, bajaUbicacion);
router.route('/:id/alta').put(authAdmin, altaUbicacion);

export default router;