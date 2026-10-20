import Usuario  from '../models/usuarios.models.js'
import jwt from 'jsonwebtoken';



const nuevoUsuario = async (req, res) => {
    const usuario = Usuario.fromObject(req.body);
    try {
        // 1. Agregamos await para esperar que la BD termine la inserción
        console.log(usuario)
        const resultado = await usuario.save();
        
        // 2. Respondemos a Postman para que no se quede colgado
        return res.status(201).json({ 
            mensaje: 'Usuario creado exitosamente', 
            datos: resultado 
        });
    } catch (error) {
        console.error('Error al guardar el usuario:', error);
        
        // 3. Devolvemos el error a Postman si algo falla en la BD
        return res.status(500).json({ 
            mensaje: 'Hubo un error al crear el usuario',
            error: error.message 
        });
    }
}
const encriptar = async (req, res) => {
    // Corrección: Validación estricta y respuesta válida de Express
    if (process.env.NODE_ENV !== "development") {
        return res.status(404).json({ mensaje: "Endpoint de prueba no disponible en producción" });
    }
    try {
        // Corrección: Agregamos await para esperar a la base de datos
        const result = await Usuario.encriptar(req.body.username);
        return res.status(200).json({
            result: result
        });
    } catch (error) {
        console.error('Error en encriptación:', error);
        return res.status(500).json({ mensaje: 'Error interno', error: error.message });
    }
}

export {
    nuevoUsuario,
    encriptar
}