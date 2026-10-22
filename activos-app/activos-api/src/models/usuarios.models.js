import { pool } from "../config/mysql.js";
import bcrypt from "bcrypt"

class Usuario {

    constructor({idUsuario, idPersona,  username, password, rol,estado }) {
        this.idUsuario=idUsuario ?? null,
        this.idPersona=idPersona,
        this.username=username,
        this.passwordHash=password,
        this.rol=rol,
        this.estado=estado
    }


    static fromObject(data) {

        const user = new Usuario(
           data
        );
        return user;
    }



    static async buscarPorUsername(username) {
/*
         execute de un procedimiento devuelve algo así:
        [[lista de usuarios][metadata del select]]
        [metadata del procedimiento]

        por eso se hace result[0][0], para acceder solo a la lista de usuarios recibidos, 
        de esta accedemos al usuario 0
*/
        const result = await pool.execute
        (
            'CALL sp_buscarUsernameUsuario( ? );', [username]
        )
        return result[0][0][0]
    }
    static async buscarPorId(id) {
        const result = await pool.execute
        (
            'CALL sp_buscarIdUsuario( ? );', [id]
        )
        return result[0][0][0]
    }

    async compararContrasenia(password){
        if (!password || !this.passwordHash) return false;
        return await bcrypt.compare(password, this.passwordHash);
    }

    async save(){
        //var outId=1;
        const result = await pool.execute
        (
            'CALL sp_nuevoUsuario( ?, ?, ?, ?, ?,@outId );', [this.idPersona,this.username,(await bcrypt.hash(this.passwordHash,10)), this.rol, this.estado]
        )
        console.log()
        return
    }

    async modificar(){
        // sp_modificarUsuario pide: pthis.idUsuario, pIdPersona, pUsername, pPassword, pRol, pEstado
        // Creo que esto puede dar problemas a futuro, yo agregaría uno para modificar la contraseña especificamente
        
        //agrego esto para evitar que si no se modifica la contraseña se hashee 2 veces
        var hashedPassword = null;
        if(!this.passwordHash){
            hashedPassword = (await pool.execute(
            'CALL  sp_buscarIdUsuario( ? );', [this.idUsuario]
        ))[0][0][0].password
        }else{
            hashedPassword = (await bcrypt.hash(this.passwordHash, 10))
        }
        const estado = (await pool.execute(
            'CALL  sp_buscarIdUsuario( ? );', [this.idUsuario]
        ))[0][0][0].estado

        const result = await pool.execute
        (
            'CALL sp_modificarUsuario( ?, ?, ?, ?, ?, ? );', 
            [
                this.idUsuario, 
                this.idPersona, 
                this.username, 
                hashedPassword, 
                this.rol, 
                estado
            ]
        );
        return result;
    }

/*
    async cambiarContraseña(nuevaContraseña) {
        if (!nuevaContraseña||nuevaContraseña=="") {
            throw new Error("No se puede cambiar la contraseña a un valor vacío");
        }
        this.passwordHash=nuevaContraseña
    }
*/
    static async encriptar(username){
        
        const datos = (await pool.execute(
            'CALL  sp_buscarUsernameUsuario( ? );', [username]
        ))[0][0][0]
        console.log(datos)
        return await pool.execute(
            'CALL sp_modificarUsuario(?,?,?,?,?,?)',[datos.idUsuario,datos.idPersona,datos.username,await bcrypt.hash(datos.password,10),datos.rol,datos.estado]
        )
        
    }

    static async darDeBaja(idUsuario) {
        const result = await pool.execute(
            'CALL sp_bajaUsuario( ? );', [idUsuario]
        );
        return result;
    }
    static async darDealta(idUsuario) {
        const result = await pool.execute(
            'CALL sp_altaUsuario( ? );', [idUsuario]
        );
        return result;
    }

}
export default Usuario 