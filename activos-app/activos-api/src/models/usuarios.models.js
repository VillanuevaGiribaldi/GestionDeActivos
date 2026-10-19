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
        /*
        this.username = username
        this._password = password;
        this.rol = rol;
        this.nombre = nombre;
        this.apellido = apellido;
        this.dni = dni;
 //       this.email = email;
        this.cargo = cargo;
        this._id = null;
        */
    }


    static fromObject(data) {
        const user = new Usuario(
           data
        );
        return user;
    }



    static async buscar(username) {
/*
         execute de un procedimiento devuelve algo así:
        [[usuario][metadata del select]]
        [metadata del procedimiento]

        por eso se hace result[0][0], para acceder solo a usuario
*/
        const result = await pool.execute
        (
            'CALL sp_buscarUsuario( ? );', [username]
        )
        return result[0][0]
    }

    async compararContrasenia(password){
        if (!password || !this.passwordHash) return false;
        console.log(await bcrypt.hash(password,10))
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
    static async encriptar(username){
        
        const datos = (await pool.execute(
            'CALL  sp_buscarUsuario( ? );', [username]
        ))[0][0][0]
        console.log(datos)
        return await pool.execute(
            'CALL sp_modificarUsuario(?,?,?,?,?,?)',[datos.idUsuario,datos.idPersona,datos.username,await bcrypt.hash(datos.password,10),datos.rol,datos.estado]
        )
        
    }

}
export default Usuario