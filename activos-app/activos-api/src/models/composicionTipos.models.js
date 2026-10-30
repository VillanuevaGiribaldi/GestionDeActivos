import { pool } from "../config/mysql.js";

class ComposicionTipo {
    constructor({ idTipoPadre, idTipoComponente, nombreTipoPadre, nombreTipoComponente, cantidadComponentesMaxima }) {
        // La BD recibe los nombres para hacer la relación
        this.nombreTipoPadre = nombreTipoPadre;
        this.nombreTipoComponente = nombreTipoComponente;
        this.cantidadComponentesMaxima = cantidadComponentesMaxima;
        
        // Para cuando queramos eliminar la relación (usamos IDs numéricos en la URL)
        this.idTipoPadre = idTipoPadre;
        this.idTipoComponente = idTipoComponente;
    }

    static fromObject(data) {
        return new ComposicionTipo(data);
    }

    async save() {
        const result = await pool.execute(
            'CALL sp_nuevaComposicionTipo( ?, ?, ? );',
            [
                this.nombreTipoPadre, 
                this.nombreTipoComponente, 
                this.cantidadComponentesMaxima
            ]
        );
        return result;
    }

    static async eliminar(idTipoPadre, idTipoComponente) {
        // Llama al SP estructurado que incluye la Regla Crítica de validación de activos huérfanos
        const result = await pool.execute(
            'CALL sp_eliminarComposicionTipo( ?, ? );', 
            [idTipoPadre, idTipoComponente]
        );
        return result;
    }

    static async listarComponentesDe(idTipoPadre) {
        // Llama al SP que acabamos de crear en MySQL
        const result = await pool.execute(
            'CALL sp_listarComponentesDe( ? );', 
            [idTipoPadre]
        );
        return result[0][0];
    }
}

export default ComposicionTipo;