import { pool } from "../config/mysql.js";

class Imagen {
    constructor({ idImagen, idActivo, ruta, estado, fecha, descripcion }) {
        this.idImagen = idImagen ?? null;
        this.idActivo = idActivo;
        this.ruta = ruta;
        this.estado = estado;
        
        // Limpiamos la fecha 
        this.fecha = fecha 
            ? fecha.substring(0, 19).replace('T', ' ') 
            : null;
            
        this.descripcion = descripcion;
    }

    static fromObject(data) {
        return new Imagen(data);
    }

    async save() {
        const result = await pool.execute(
            'CALL sp_nuevaImagen( ?, ?, ?, ?, ?, @pIdImagen );',
            [
                this.idActivo, 
                this.ruta, 
                this.descripcion, 
                this.estado, 
                this.fecha
            ]
        );
        return result;
    }

    async modificar() {
        const result = await pool.execute(
            'CALL sp_modificarImagen( ?, ?, ?, ?, ?, ? );', 
            [
                this.idImagen,
                this.idActivo,
                this.ruta,
                this.descripcion,
                this.estado,
                this.fecha
            ]
        );
        return result;
    }

    static async darDeBaja(idImagen) {
        const result = await pool.execute('CALL sp_bajaImagen( ? );', [idImagen]);
        return result;
    }

    static async darDeAlta(idImagen) {
        const result = await pool.execute('CALL sp_altaImagen( ? );', [idImagen]);
        return result;
    }

    static async buscarPorId(idImagen) {
        const result = await pool.execute('CALL sp_buscarIdImagen( ? );', [idImagen]);
        return result[0][0][0]; 
    }

    static async listarImagenes(estado, idActivo = null) {
        const result = await pool.execute('CALL sp_listarImagenes( ?, ? );', [estado || null, idActivo]);
        return result[0][0]; 
    }
}

export default Imagen;