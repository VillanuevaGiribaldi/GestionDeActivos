import { pool } from "../config/mysql.js";

// Normaliza a 'YYYY-MM-DD' (las columnas son DATE) o null
const aFecha = (f) => (f ? String(f).substring(0, 10) : null);

class Mantenimiento {
    constructor({
        idMantenimiento, idActivo, idProveedor, fallaReportada, fechaEnvio,
        reparacionRealizada, fechaDevolucion, costoTotal,
        idEstadoEnReparacion, idEstadoPostReparacion
    }) {
        this.idMantenimiento = idMantenimiento ?? null;
        this.idActivo = idActivo ?? null;
        this.idProveedor = idProveedor ?? null;
        this.fallaReportada = fallaReportada ?? null;
        this.fechaEnvio = aFecha(fechaEnvio);
        this.reparacionRealizada = reparacionRealizada ?? null;
        this.fechaDevolucion = aFecha(fechaDevolucion);
        this.costoTotal = costoTotal ?? null;
        this.idEstadoEnReparacion = idEstadoEnReparacion ?? null;
        this.idEstadoPostReparacion = idEstadoPostReparacion ?? null;
    }

    static fromObject(data) {
        return new Mantenimiento(data);
    }

    // sp_nuevoMantenimiento tiene OUT param: misma conexión para leer la variable de sesión
    async save(idUsuario) {
        const conn = await pool.getConnection();
        try {
            await conn.execute(
                'CALL sp_nuevoMantenimiento( ?, ?, ?, ?, ?, ?, @pIdMantenimiento );',
                [
                    this.idActivo,
                    this.idProveedor,
                    this.fallaReportada,
                    this.fechaEnvio,
                    this.idEstadoEnReparacion,
                    idUsuario
                ]
            );
            const [rows] = await conn.query('SELECT @pIdMantenimiento AS idMantenimiento;');
            return rows[0].idMantenimiento;
        } finally {
            conn.release();
        }
    }

    async modificar() {
        return await pool.execute(
            'CALL sp_modificarMantenimiento( ?, ?, ?, ?, ?, ?, ? );',
            [
                this.idMantenimiento,
                this.idProveedor,
                this.fallaReportada,
                this.fechaEnvio,
                this.reparacionRealizada,
                this.fechaDevolucion,
                this.costoTotal
            ]
        );
    }

    // Cierra el mantenimiento (retorno de soporte técnico)
    async finalizar(idUsuario) {
        return await pool.execute(
            'CALL sp_finMantenimiento( ?, ?, ?, ?, ?, ? );',
            [
                this.idMantenimiento,
                this.reparacionRealizada,
                this.fechaDevolucion,
                this.costoTotal,
                this.idEstadoPostReparacion,
                idUsuario
            ]
        );
    }

    static async darDeBaja(idMantenimiento) {
        return await pool.execute('CALL sp_bajaMantenimiento( ? );', [idMantenimiento]);
    }

    static async darDeAlta(idMantenimiento) {
        return await pool.execute('CALL sp_altaMantenimiento( ? );', [idMantenimiento]);
    }

    static async buscarPorId(idMantenimiento) {
        const result = await pool.execute('CALL sp_buscarIdMantenimiento( ? );', [idMantenimiento]);
        return result[0][0][0];
    }

    static async listarMantenimientos(estado, idActivo) {
        const result = await pool.execute(
            'CALL sp_listarMantenimientos( ?, ? );',
            [estado ?? null, idActivo ?? null]
        );
        return result[0][0];
    }
}

export default Mantenimiento;