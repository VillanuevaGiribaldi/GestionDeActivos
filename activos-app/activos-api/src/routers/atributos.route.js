import { Router } from "express";
import {
    nuevoAtributo,
    modificarAtributo,
    eliminarAtributo,
    getAtributo,
    listarAtributos
} from '../controllers/atributos.controller.js';
import { authDefault } from "../controllers/auth.controller.js";

const router = Router();

router.route('/').get(authDefault, listarAtributos);
router.route('/nuevo').post(authDefault, nuevoAtributo);

router.route('/:id').get(authDefault, getAtributo);
router.route('/:id').put(authDefault, modificarAtributo);
router.route('/:id').delete(authDefault, eliminarAtributo);

export default router;