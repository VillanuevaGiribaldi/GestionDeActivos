import { Router } from "express";
import { 
    nuevaFactura, 
    getFactura, 
    listarFacturas, 
    modificarFactura, 
    bajaFactura, 
    altaFactura 
} from '../controllers/facturas.controller.js';
import { authDefault, authView } from "../controllers/auth.controller.js";

const router = Router();

router.route('/').get(authView, listarFacturas);
router.route('/nueva').post(authDefault, nuevaFactura);
router.route('/:id').get(authView, getFactura);
router.route('/:id').put(authDefault, modificarFactura);

// Rutas lógicas de estado
router.route('/:id').delete(authDefault, bajaFactura);
router.route('/:id/alta').put(authDefault, altaFactura);

export default router;