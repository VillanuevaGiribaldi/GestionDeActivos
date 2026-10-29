import { pool } from "../config/mysql.js";

class Atributo {
    constructor({ idAtributo, idTipo, nombre, porDefecto, obligatorio }) {
        this.idAtributo = idAtributo ?? null;
        this.idTipo = idTipo ?? null;
        this.nombre = nombre ?? null;
        this.porDefecto = porDefecto ?? null;
        this.obligatorio = obligatorio ? 1 : 0;
    }

    static fromObject(data) {
        return new Atributo(data ?? {});
    }

    // sp_nuevoAtributo(pIdTipo, pNombre, pPorDefecto, pObligatorio, OUT pIdAtributo)
    async save() {
        const connection = await pool.getConnection();
        try {
            await connection.execute(
                'CALL sp_nuevoAtributo( ?, ?, ?, ?, @pIdAtributo );',
                [this.idTipo, this.nombre, this.porDefecto, this.obligatorio]
            );
            const [rows] = await connection.query('SELECT @pIdAtributo AS idAtributo;');
            return rows[0].idAtributo;
        } finally {
            connection.release();
        }
    }

    // sp_modificarAtributo(pIdAtributo, pIdTipo, pNombre, pPorDefecto, pObligatorio)
    async modificar() {
        return await pool.execute(
            'CALL sp_modificarAtributo( ?, ?, ?, ?, ? );',
            [this.idAtributo, this.idTipo, this.nombre, this.porDefecto, this.obligatorio]
        );
    }

    async eliminar() {
        return await pool.execute(
            'CALL sp_eliminarAtributo( ? );',
            [this.idAtributo]
        );
    }

    static async buscarPorId(idAtributo) {
        const result = await pool.execute('CALL sp_buscarIdAtributo( ? );', [idAtributo]);
        return result[0][0][0];
    }

    static async listarAtributos(idTipo = null) {
        const result = await pool.execute(
            'CALL sp_listarAtributos( ? );',
            [idTipo ?? null]
        );
        return result[0][0];
    }
}

export default Atributo;