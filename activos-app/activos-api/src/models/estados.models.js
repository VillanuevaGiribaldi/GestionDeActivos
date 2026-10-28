import { pool } from "../config/mysql.js";

class Estado {
    constructor({ idEstado, nombre, descripcion, estado }) {
        this.idEstado = idEstado ?? null;
        this.nombre = nombre;
        this.descripcion = descripcion ?? null;
        this.estado = estado ?? null;
    }

    static fromObject(data) {
        return new Estado(data);
    }

    // sp_nuevoEstado(pNombre, pDescripcion, pEstado, OUT pIdEstado)
    // Se usa una sola conexión para poder leer la variable de sesión @outId
    async save() {
        const connection = await pool.getConnection();
        try {
            await connection.execute(
                'CALL sp_nuevoEstado( ?, ?, ?, @outIdEstado );',
                [this.nombre, this.descripcion, this.estado]
            );
            const [rows] = await connection.query('SELECT @outIdEstado AS idEstado;');
            return rows[0].idEstado;
        } finally {
            connection.release();
        }
    }

    // sp_modificarEstado(pIdEstado, pNombre, pDescripcion)
    async modificar() {
        return await pool.execute(
            'CALL sp_modificarEstado( ?, ?, ? );',
            [this.idEstado, this.nombre, this.descripcion]
        );
    }

    static async darDeBaja(idEstado) {
        return await pool.execute('CALL sp_bajaEstado( ? );', [idEstado]);
    }

    static async darDeAlta(idEstado) {
        return await pool.execute('CALL sp_altaEstado( ? );', [idEstado]);
    }

    static async buscarPorId(idEstado) {
        const result = await pool.execute('CALL sp_buscarIdEstado( ? );', [idEstado]);
        return result[0][0][0];
    }

    static async listarEstados(estado) {
        const result = await pool.execute('CALL sp_listarEstados( ? );', [estado]);
        return result[0][0];
    }
}

export default Estado;