import Usuario  from '../models/usuarios.models.js'
import jwt from 'jsonwebtoken';


const loginUsuario = async (req,res) => { 
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
        

        // Comparo texto plano, pero debe ser HASH
        //const passwordValida = (password === usuarioData.password);
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
const nuevoUsuario = async (req,res) => {
    const usuario = Usuario.fromObject(req.body)
    try {
        console.log(usuario.save())
    } catch (error) {
        console.log(error)
    }
    
}

export {
    loginUsuario,
    nuevoUsuario
}