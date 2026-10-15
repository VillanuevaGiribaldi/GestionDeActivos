import express from "express"

import { login } from './controllers/auth.controller.js'

const app = express()
app.use(express.json())

// importar las rutas
import userRouter from './routers/usuarios.route.js'

// declarar las rutas
app.use("/api/auth", userRouter)

app.post("/api/login", login)

export default app

