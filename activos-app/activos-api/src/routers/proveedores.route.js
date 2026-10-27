import { Router } from "express";
import { 
    nuevoProveedor, 
    getProveedor, 
    listarProveedores, 
    modificarProveedor, 
    bajaProveedor, 
    altaProveedor 
} from '../controllers/proveedores.controller.js';
import { authDefault } from "../controllers/auth.controller.js";

const router = Router();

// RUTA PARA LISTAR TODOS (Ej: GET /api/proveedor o GET /api/proveedor?estado=A)
router.route('/').get(authDefault, listarProveedores);

router.route('/nuevo').post(authDefault, nuevoProveedor);
router.route('/:id').get(authDefault, getProveedor);
router.route('/:id').put(authDefault, modificarProveedor);

// Alta y Baja lógica (Nota: corregido a ruta limpia /:id para el DELETE)
router.route('/:id').delete(authDefault, bajaProveedor);
router.route('/:id/alta').put(authDefault, altaProveedor);

export default router;