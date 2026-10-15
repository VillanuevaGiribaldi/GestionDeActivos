import { pool } from "../config/mysql.js";

class Usuario {

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

}
export default Usuario