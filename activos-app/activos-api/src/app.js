import express from "express"

const app = express()
app.use(express.json())

// importar las rutas
import userRouter from './routers/usuarios.route.js'
import { login } from "./controllers/auth.controller.js"
import personasRouter from './routers/personas.route.js';
import marcasRouter from "./routers/marcas.route.js";
import tiposRouter from "./routers/tipos.route.js";
import proveedoresRouter from "./routers/proveedores.route.js";
import ubicacionesRouter from "./routers/ubicaciones.route.js";
import estadosRouter from './routers/estados.route.js';
import facturasRouter from "./routers/facturas.route.js";
import imagenesRouter from './routers/imagenes.route.js';
import atributosRouter from './routers/atributos.route.js';
import mantenimientosRouter from './routers/mantenimientos.route.js';

// declarar las rutas
app.use("/api/usuario", userRouter)
app.post("/api/login", login)
app.use('/api/persona', personasRouter)
app.use('/api/marca', marcasRouter)
app.use('/api/tipo',tiposRouter)
app.use('/api/proveedor', proveedoresRouter)
app.use('/api/ubicacion', ubicacionesRouter);
app.use('/api/estado', estadosRouter);
app.use('/api/factura', facturasRouter);
app.use('/api/imagen', imagenesRouter)
app.use('/api/atributo', atributosRouter)
app.use('/api/mantenimiento', mantenimientosRouter);

export default app

