import { Router } from "express";
import { 
    nuevaComposicion, 
    getComponentesPermitidos, 
    eliminarComposicion 
} from '../controllers/composicionTipos.controller.js';
import { authAdmin, authDefault, authView } from "../controllers/auth.controller.js";

const router = Router();

// Crear nueva regla de jerarquía
router.route('/nuevo').post(authAdmin, nuevaComposicion);

// Ver qué componentes permite un Tipo (Ej: GET /api/composicion/padre/5)
router.route('/padre/:idTipoPadre').get(authDefault, getComponentesPermitidos);

// Eliminar una regla específica
router.route('/:idTipoPadre/:idTipoComponente').delete(authAdmin, eliminarComposicion);

export default router;