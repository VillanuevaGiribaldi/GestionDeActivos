import { Router } from "express";
import {
    nuevoTipo,
    modificarTipo,
    bajaTipo,
    altaTipo,
    getTipo,
    listarTipos
} from '../controllers/tipos.controller.js';
import { authAdmin, authDefault, authView } from "../controllers/auth.controller.js";

const router = Router();

router.route('/').get(authView, listarTipos);
router.route('/nuevo').post(authAdmin, nuevoTipo);

router.route('/:id').get(authView, getTipo);
router.route('/:id').put(authAdmin, modificarTipo);
router.route('/:id').delete(authAdmin, bajaTipo);
router.route('/:id/alta').put(authAdmin, altaTipo);

export default router;