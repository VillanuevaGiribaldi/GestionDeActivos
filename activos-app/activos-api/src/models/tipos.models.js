import { pool } from "../config/mysql.js";

class Tipo {
    constructor({ idTipo, nombre, descripcion, estado }) {
        this.idTipo = idTipo ?? null;
        this.nombre = nombre ?? null;
        this.descripcion = descripcion ?? null;
        this.estado = estado ?? null;
    }

    static fromObject(data) {
        return new Tipo(data);
    }

    // Devuelve el id generado. Se usa una única conexión porque las variables
    // de sesión (@pIdTipo) solo existen dentro de la misma conexión.
    async save() {
        const connection = await pool.getConnection();
        try {
            await connection.execute(
                'CALL sp_nuevoTipo( ?, ?, ?, @pIdTipo );',
                [this.nombre, this.descripcion, this.estado]
            );
            const [rows] = await connection.query('SELECT @pIdTipo AS idTipo;');
            return rows[0].idTipo;
        } finally {
            connection.release();
        }
    }

    async modificar() {
        return await pool.execute(
            'CALL sp_modificarTipo( ?, ?, ? );',
            [this.idTipo, this.nombre, this.descripcion]
        );
    }

    static async darDeBaja(idTipo) {
        return await pool.execute('CALL sp_bajaTipo( ? );', [idTipo]);
    }

    static async darDeAlta(idTipo) {
        return await pool.execute('CALL sp_altaTipo( ? );', [idTipo]);
    }

    static async buscarPorId(idTipo) {
        const result = await pool.execute('CALL sp_buscarIdTipo( ? );', [idTipo]);
        return result[0][0][0];
    }

    static async listarTipos(estado) {
        const result = await pool.execute('CALL sp_listarTipos( ? );', [estado]);
        return result[0][0];
    }
}

export default Tipo;