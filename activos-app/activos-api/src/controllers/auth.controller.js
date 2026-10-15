import jwt from 'jsonwebtoken';

const login = async (req, res) => {
    const { username, password } = req.body;

    if (!username || !password) {
        return res.status(400).json({ mensaje: 'Por favor, ingrese usuario y contraseña' });
    }

    try {
        // Prueba. Lo ideal es insertar el procedimiento sp_buscarUsuario
        const usuario = await buscarUsuarioEnDB(username); 

        if (!usuario) {
            return res.status(401).json({ mensaje: 'Credenciales inválidas' });
        }
        // Comparo texto plano, pero debe ser HASH
        const passwordValida = (password === usuario.password);

        if (!passwordValida) {
            return res.status(401).json({ mensaje: 'Credenciales inválidas' });
        }
        // genero el token
        const token = jwt.sign(
            { 
                id: usuario.idUsuario, 
                rol: usuario.rol 
            },
            process.env.JWT_SECRET || 'secreto_de_prueba_temporal', 
            { expiresIn: '8h' }
        );

        // Respuesta
        res.status(200).json({
            mensaje: 'Autenticación exitosa',
            token: token,
            usuario: {
                id: usuario.idUsuario,
                username: usuario.username,
                rol: usuario.rol
            }
        });

    } catch (error) {
        console.error('Error en el login:', error);
        res.status(500).json({ mensaje: 'Error interno del servidor' });
    }
};


async function buscarUsuarioEnDB(usernameABuscar) {
    if (usernameABuscar === 'jperez') {
        return {
            idUsuario: 1,
            username: 'jperez',
            password: 'contrasenia1', 
            rol: 'ADMIN_IT'
        };
    }
    return null;
}

// Exportamos la función para poder usarla en las rutas
export { login };