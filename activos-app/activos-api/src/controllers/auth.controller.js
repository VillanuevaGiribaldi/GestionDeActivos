import Usuario  from '../models/usuarios.models.js'
import jwt from 'jsonwebtoken';


const login = async (req,res) => {

    
    const {username, password} = req.body 
    console.log(`El usuario [${username}] está intentando loguearse`) 
    if (!username || !password) {
        return res.status(400).json({ mensaje: 'Por favor, ingrese usuario y contraseña' });
    }
    try {

        const usuarioData = (await Usuario.buscarPorUsername(username))
        if (!usuarioData || usuarioData.length > 1 || usuarioData.username != username) {
            return res.status(401).json({ mensaje: 'Credenciales inválidas' });
        }
        const usuario = Usuario.fromObject(usuarioData)
        const passwordValida = await usuario.compararContrasenia(password);
        if (!passwordValida) {
            return res.status(401).json({ mensaje: 'Credenciales inválidas' });
        }
        // genero el token
        const token = jwt.sign(
            { 
                id: usuarioData.idUsuario, 
                rol: usuarioData.rol 
            },
            process.env.JWT_SECRET || 'secreto_de_prueba_temporal', 
            { expiresIn: process.env.TOKEN_DURATION }
        );

        // Respuesta
        return res.status(200).json({
            mensaje: 'Autenticación exitosa',
            token: token,
            usuario: {
                id: usuarioData.idUsuario,
                username: usuarioData.username,
                rol: usuarioData.rol
            }
        });
    } catch (error) {
        console.log(error)
        res.status(500).json({
            mensaje: 'error al buscar'
        })
    }  
    
}

const authAdmin = async (req, res, next) => {
    try {
        const decoded = jwt.verify(req.headers.authorization.split(" ")[1], process.env.JWT_SECRET || 'secreto_de_prueba_temporal');
        if (decoded.rol !== 'ADMIN_IT') {
            console.log(decoded)
            return res.status(403).json({ message: "No tiene permiso para realizar esta accion. Se requiere rol de Administrador." });
        }
        req.usuario = decoded;
        next();
    } catch (error) {
        return res.status(401).json({ message: "Token no proporcionado o sesión expirada, vueva a iniciar sesión" });
    }
};

const authDefault = async (req, res, next) => {
    try {
        const decoded = jwt.verify(req.headers.authorization.split(" ")[1], process.env.JWT_SECRET || 'secreto_de_prueba_temporal');
        // Permite el paso si el rol incluye 'IT' Ej. ADMIN_IT, SOPORTE_IT, PASANTE_IT)
        if (!decoded.rol.includes('IT')) {
            return res.status(403).json({ message: "Acceso denegado. Se requiere ser empleado de TI." });
        }
        req.usuario = decoded;
        next();
    } catch (error) {
        return res.status(401).json({ message: "Token no proporcionado o sesión expirada, vueva a iniciar sesión" });
    }
};

const authView = async (req, res, next) => {
    try {
        // El permiso de vista solo requiere que el token sea válido (cualquier usuario logueado)
        const decoded = jwt.verify(req.headers.authorization.split(" ")[1], process.env.JWT_SECRET || 'secreto_de_prueba_temporal');
        //req.usuario = decoded;
        next();
    } catch (error) {
        console.log(error)
        return res.status(401).json({ message: "Token no proporcionado o sesión expirada, vueva a iniciar sesión" });
    }
};

export { login, authAdmin, authDefault, authView };