import { Router } from "express";
import { 
    nuevaComposicion, 
    getComponentesPermitidos, 
    eliminarComposicion 
} from '../controllers/composicionTipos.controller.js';
import { authDefault, authView } from "../controllers/auth.controller.js";

const router = Router();

// Crear nueva regla de jerarquía
router.route('/nuevo').post(authDefault, nuevaComposicion);

// Ver qué componentes permite un Tipo (Ej: GET /api/composicion/padre/5)
router.route('/padre/:idTipoPadre').get(authView, getComponentesPermitidos);

// Eliminar una regla específica
router.route('/:idTipoPadre/:idTipoComponente').delete(authDefault, eliminarComposicion);

export default router;