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
const encriptar= async (req,res) => {
    if(! process.env.NODE_ENV==="development"){
        res(404)
    }
    try {
        const result = Usuario.encriptar(req.body.username)
        res.status(200).json({
            result: result
        })
    } catch (error) {
        
    }
}

export {
    nuevoUsuario,
    encriptar
}