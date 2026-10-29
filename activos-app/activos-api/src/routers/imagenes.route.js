import { Router } from "express";
import { 
    nuevaImagen, 
    getImagen, 
    listarImagenes, 
    modificarImagen, 
    bajaImagen, 
    altaImagen 
} from '../controllers/imagenes.controller.js';
import { authDefault, authView } from "../controllers/auth.controller.js";

const router = Router();

router.route('/').get(authView, listarImagenes);

// Escritura restringida a IT
router.route('/nueva').post(authDefault, nuevaImagen);
router.route('/:id').get(authView, getImagen);
router.route('/:id').put(authDefault, modificarImagen);

// Manejo de estados
router.route('/:id').delete(authDefault, bajaImagen);
router.route('/:id/alta').put(authDefault, altaImagen);

export default router;