import { pool } from "../config/mysql.js";

class Marca {
    constructor({ idMarca, nombre, descripcion, estado }) {
        this.idMarca = idMarca ?? null;
        this.nombre = nombre;
        this.descripcion = descripcion;
        this.estado = estado;
    }

    static fromObject(data) {
        return new Marca(data);
    }

    async save() {
        // sp_nuevaMarca requiere: pNombre, pDescripcion, pEstado, OUT pIdMarca
        const result = await pool.execute(
            'CALL sp_nuevaMarca( ?, ?, ?, @pIdMarca );',
            [this.nombre, this.descripcion, this.estado]
        );
        return result;
    }

    async modificar() {
        const result = await pool.execute(
            'CALL sp_modificarMarca( ?, ?, ? );', 
            [
                this.idMarca,
                this.nombre,
                this.descripcion
            ]
        );
        return result;
    }

    static async darDeBaja(idMarca) {
        const result = await pool.execute('CALL sp_bajaMarca( ? );', [idMarca]);
        return result;
    }

    static async darDeAlta(idMarca) {
        const result = await pool.execute('CALL sp_altaMarca( ? );', [idMarca]);
        return result;
    }

    static async buscarPorId(idMarca) {
        const result = await pool.execute('CALL sp_buscarIdMarca( ? );', [idMarca]);
        return result[0][0][0]; 
    }
    static async listarMarcas(estado) {
        return (await pool.execute('CALL sp_listarMarcas( ? );',[estado]))[0][0]
    }
}

export default Marca;