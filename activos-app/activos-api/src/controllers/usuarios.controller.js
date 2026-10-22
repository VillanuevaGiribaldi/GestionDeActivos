import Usuario  from '../models/usuarios.models.js'
import jwt from 'jsonwebtoken';


/*
    @openAPI
    
*/
const nuevoUsuario = async (req, res) => {
    const usuario = Usuario.fromObject(req.body.usuario);
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

const modificarUsuario = async (req, res) => {
    try {


        const idUrl = parseInt(req.params.id);
        // Validación de correspondencia de IDs
        if (idUrl !== parseInt(req.body.usuario.idUsuario)) {
            return res.status(400).json({
                message: "Los IDs de la URL y del cuerpo no se corresponden"
            });
        }
        console.log(`Modificando el usuario ${idUrl}`);
        if(req.body.usuario.estado=='B'){

        }

        // Instanciación del usuario a partir del cuerpo
        const usuario = Usuario.fromObject(req.body.usuario);
        
        // Ejecución de la modificación en BD
        await usuario.modificar();
        
        return res.status(200).json({
            message: "Usuario modificado exitosamente"
        });

    } catch (error) {
        console.error('Error al modificar el usuario:', error);
        return res.status(500).json({
            message: "Error al modificar el usuario",
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

const bajaUsuario = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        console.log(`Dando de baja al usuario ${idUrl}`);
        
        await Usuario.darDeBaja(idUrl);
        
        return res.status(200).json({
            message: "Usuario dado de baja exitosamente"
        });

    } catch (error) {
        console.error('Error al dar de baja el usuario:', error);
        return res.status(500).json({
            message: "Error al dar de baja el usuario",
            error: error.message
        });
    }
}

const altaUsuario = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        console.log(`Dando de alta al usuario ${idUrl}`);
        
        await Usuario.darDealta(idUrl);
        
        return res.status(200).json({
            message: "Usuario dado de alta exitosamente"
        });

    } catch (error) {
        console.error('Error al dar de alta el usuario:', error);
        return res.status(500).json({
            message: "Error al dar de alta el usuario",
            error: error.message
        });
    }
}


export {
    nuevoUsuario,
    modificarUsuario,
    bajaUsuario,
    altaUsuario,
    encriptar
}