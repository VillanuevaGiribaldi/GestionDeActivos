import express from "express"


const app = express()
app.use(express.json())

// importar las rutas
import userRouter from './routers/usuarios.route.js'

// declarar las rutas
app.use("/api/auth", userRouter)


export default app

