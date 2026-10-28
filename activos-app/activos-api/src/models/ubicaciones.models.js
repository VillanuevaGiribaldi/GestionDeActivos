import { pool } from "../config/mysql.js";

class Ubicacion {
    constructor({ idUbicacion, idUbicacionPadre, nombre, descripcion, estado }) {
        this.idUbicacion = idUbicacion ?? null;
        this.idUbicacionPadre = idUbicacionPadre ?? null;
        this.nombre = nombre ?? null;
        this.descripcion = descripcion ?? null;
        this.estado = estado ?? null;
    }

    static fromObject(data) {
        return new Ubicacion(data);
    }

    // Devuelve el id generado (el OUT param se lee en la misma conexión)
    async save() {
        const conn = await pool.getConnection();
        try {
            await conn.execute(
                'CALL sp_nuevaUbicacion( ?, ?, ?, ?, @pIdUbicacion );',
                [this.idUbicacionPadre, this.nombre, this.descripcion, this.estado]
            );
            const [rows] = await conn.query('SELECT @pIdUbicacion AS idUbicacion;');
            return rows[0].idUbicacion;
        } finally {
            conn.release();
        }
    }

    async modificar() {
        const result = await pool.execute(
            'CALL sp_modificarUbicacion( ?, ?, ?, ? );',
            [this.idUbicacion, this.idUbicacionPadre, this.nombre, this.descripcion]
        );
        return result;
    }

    static async darDeBaja(idUbicacion) {
        const result = await pool.execute('CALL sp_bajaUbicacion( ? );', [idUbicacion]);
        return result;
    }

    static async darDeAlta(idUbicacion) {
        const result = await pool.execute('CALL sp_altaUbicacion( ? );', [idUbicacion]);
        return result;
    }

    static async buscarPorId(idUbicacion) {
        const result = await pool.execute('CALL sp_buscarIdUbicacion( ? );', [idUbicacion]);
        return result[0][0][0];
    }

    static async listarUbicaciones(estado) {
        return (await pool.execute('CALL sp_listarUbicaciones( ? );', [estado ?? null]))[0][0];
    }
}

export default Ubicacion;