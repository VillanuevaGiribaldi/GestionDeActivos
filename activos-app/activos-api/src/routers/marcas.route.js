import { Router } from "express";
import { nuevaMarca, getMarca, modificarMarca, bajaMarca, altaMarca, listarMarcas } from '../controllers/marcas.controller.js';
import { authDefault } from "../controllers/auth.controller.js";

const router = Router();

// Protegidas con authDefault (Empleados de TI)
router.route('/nueva').post(authDefault, nuevaMarca);
router.route('/:id').get(authDefault, getMarca);
router.route('/:id').put(authDefault, modificarMarca);

// Alta y Baja lógica
router.route('/:id', '/:id/baja').delete(authDefault, bajaMarca);
router.route('/:id/alta').put(authDefault, altaMarca);

// lista completa de marcas
router.route('').get(authDefault, listarMarcas );

export default router;