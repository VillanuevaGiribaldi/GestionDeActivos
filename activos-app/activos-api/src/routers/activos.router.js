import { Router } from "express";
import { 
    nuevoActivo, 
    getActivo, 
    listarActivos, 
    modificarActivo, 
    bajaActivo 
} from '../controllers/activos.controller.js';
import { authDefault, authView } from "../controllers/auth.controller.js";

const router = Router();

router.route('/').get(authView, listarActivos);
router.route('/:id').get(authView, getActivo);

router.route('/nuevo').post(authDefault, nuevoActivo);
router.route('/:id').put(authDefault, modificarActivo);

// Borrado Lógico con Historial
router.route('/:id').delete(authDefault, bajaActivo);

export default router;