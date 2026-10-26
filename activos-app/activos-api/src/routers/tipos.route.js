import { Router } from "express";
import {
    nuevoTipo,
    modificarTipo,
    bajaTipo,
    altaTipo,
    getTipo,
    listarTipos
} from '../controllers/tipos.controller.js';
import { authDefault } from "../controllers/auth.controller.js";

const router = Router();

router.route('/').get(authDefault, listarTipos);
router.route('/nuevo').post(authDefault, nuevoTipo);

router.route('/:id').get(authDefault, getTipo);
router.route('/:id').put(authDefault, modificarTipo);
router.route('/:id').delete(authDefault, bajaTipo);
router.route('/:id/alta').put(authDefault, altaTipo);

export default router;