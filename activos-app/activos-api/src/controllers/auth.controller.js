import Usuario  from '../models/usuarios.models.js'
import jwt from 'jsonwebtoken';


const login = async (req,res) => {
    console.log("Entró al controlador real") 
    const {username, password} = req.body 
    if (!username || !password) {
        return res.status(400).json({ mensaje: 'Por favor, ingrese usuario y contraseña' });
    }
    try {

        const usuarioData = (await Usuario.buscar(username))[0]
        console.log(usuarioData)
        const usuario = Usuario.fromObject(usuarioData)
        console.log(usuario)

        if (!usuarioData || usuarioData.length > 1) {
            return res.status(401).json({ mensaje: 'Credenciales inválidas' });
        }
        
        const passwordValida = await usuario.compararContrasenia(password);
        console.log(passwordValida)
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
            { expiresIn: '8h' }
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
    }  
    
}

const authAdmin = async (req,res,next) => {
    if(! (jwt.verify(req.body.token, ('secreto_de_prueba_temporal') ).rol === 'ADMIN_IT')){
        res.status(401).json({
            message:"No tiene permiso para realizar esta acción"
        })
    }

    next();
}
export { login,authAdmin };