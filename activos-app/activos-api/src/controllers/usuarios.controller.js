import Usuario  from '../models/usuarios.models.js'

const loginUsuario = async (req,res) => { 
    try {
        /* res.status(201).json({
            message: "test message"
        }) */
        
        const {username, password} = req.body
        const user = await Usuario.buscar(username)
        res.status(201).json({
            message: "usuario encontrado",
            user: user,
        })
    } catch (error) {
        console.log(error)
    }  
    
}
export {
    loginUsuario
}