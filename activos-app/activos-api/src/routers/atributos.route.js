import { Router } from "express";
import {
    nuevoAtributo,
    modificarAtributo,
    eliminarAtributo,
    getAtributo,
    listarAtributos
} from '../controllers/atributos.controller.js';
import { authAdmin, authDefault } from "../controllers/auth.controller.js";

const router = Router();

router.route('/').get(authDefault, listarAtributos);
router.route('/nuevo').post(authAdmin, nuevoAtributo);

router.route('/:id').get(authDefault, getAtributo);
router.route('/:id').put(authAdmin, modificarAtributo);
router.route('/:id').delete(authAdmin, eliminarAtributo);

export default router;