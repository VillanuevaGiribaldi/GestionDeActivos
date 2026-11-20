import { pool } from "../config/mysql.js";

const formatearFechaSQL = (fecha, esFin = false) => {
    if (!fecha || fecha.trim() === '') return null;
    
    // Si llega solo YYYY-MM-DD desde el input date del frontend
    if (fecha.length === 10) {
        return `${fecha} ${esFin ? '23:59:59' : '00:00:00'}`;
    }
    
    // Si llega en formato ISO (YYYY-MM-DDTHH:mm:ss.000Z), lo adaptamos a MySQL
    return fecha.substring(0, 19).replace('T', ' ');
};

class Historial {
    static async listarHistorial(fechaInicio = null, fechaFin = null) {
        const result = await pool.execute(
            'CALL sp_verHistorialFechas( ?, ? );',
            [fechaInicio || null, fechaFin || null]
        );
        return result[0][0];
    }

    static async listarPorActivo(idActivo) {
        const result = await pool.execute(
            'CALL sp_verHistorialActivo( ? );',
            [idActivo]
        );
        return result[0][0];
    }
}

export default Historial;