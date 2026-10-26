import express from "express"

const app = express()
app.use(express.json())

// importar las rutas
import userRouter from './routers/usuarios.route.js'
import { login } from "./controllers/auth.controller.js"
import personasRouter from './routers/personas.route.js';
import marcasRouter from "./routers/marcas.route.js";
import tiposRouter from "./routers/tipos.route.js";

// declarar las rutas
app.use("/api/usuario", userRouter)
app.post("/api/login", login)
app.use('/api/persona', personasRouter);
app.use('/api/marca', marcasRouter)
app.use('/api/tipo',tiposRouter)
export default app

