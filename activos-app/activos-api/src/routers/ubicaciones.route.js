import { Router } from "express";
import {
    nuevaUbicacion,
    getUbicacion,
    modificarUbicacion,
    bajaUbicacion,
    altaUbicacion,
    listarUbicaciones
} from '../controllers/ubicaciones.controller.js';
import { authDefault } from "../controllers/auth.controller.js";

const router = Router();

router.route('/').get(authDefault, listarUbicaciones);
router.route('/nueva').post(authDefault, nuevaUbicacion);

router.route('/:id').get(authDefault, getUbicacion);
router.route('/:id').put(authDefault, modificarUbicacion);

// Baja y alta lógica
router.route('/:id').delete(authDefault, bajaUbicacion);
router.route('/:id/baja','/:id').delete(authDefault, bajaUbicacion);
router.route('/:id/alta').put(authDefault, altaUbicacion);

export default router;