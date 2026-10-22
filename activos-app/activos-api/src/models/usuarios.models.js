import { pool } from "../config/mysql.js";
import bcrypt from "bcrypt"

class Usuario {
    //constructor(username, passwordHash, rol , nombre, apellido, dni, cargo ) {
    constructor({idPersona,  username, password, rol,estado }) {
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

        por eso se hace result[0][0], para acceder solo a la lista de usuarios recibidos, de esta accedemos al usuario 0
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
        var outId=null;
        const result = await pool.execute
        (
            'CALL sp_nuevoUsuario( ?, ?, ?, ?, ?,? );', [this.idPersona,this.username,(await bcrypt.hash(this.passwordHash,10)), this.rol, this.estado, outId]
        )
        console.log(outId)
        return
    }
    async modificar(idUsuario){
        // sp_modificarUsuario pide: pIdUsuario, pIdPersona, pUsername, pPassword, pRol, pEstado
        const result = await pool.execute
        (
            'CALL sp_modificarUsuario( ?, ?, ?, ?, ?, ? );', 
            [
                idUsuario, 
                this.idPersona, 
                this.username, 
                (await bcrypt.hash(this.passwordHash, 10)), 
                this.rol, 
                this.estado
            ]
        );
        return result;
    }
    static async encriptar(username){
        
        const datos = (await pool.execute(
            'CALL  sp_buscarUsuario( ? );', [username]
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

}
export default Usuario 