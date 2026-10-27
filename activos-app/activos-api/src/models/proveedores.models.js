import { pool } from "../config/mysql.js";

class Proveedor {
    constructor({ idProveedor, nombre, direccion, telefono, mail, descripcion, estado }) {
        this.idProveedor = idProveedor ?? null;
        this.nombre = nombre;
        this.direccion = direccion;
        this.telefono = telefono;
        this.mail = mail;
        this.descripcion = descripcion;
        this.estado = estado;
    }

    static fromObject(data) {
        return new Proveedor(data);
    }

    async save() {
        const result = await pool.execute(
            'CALL sp_nuevoProveedor( ?, ?, ?, ?, ?, @pIdProveedor );',
            [this.nombre, this.direccion, this.telefono, this.mail, this.descripcion]
        );
        return result;
    }

    async modificar() {
        // sp_modificarProveedor NO recibe el estado
        const result = await pool.execute(
            'CALL sp_modificarProveedor( ?, ?, ?, ?, ?, ? );', 
            [
                this.idProveedor,
                this.nombre,
                this.direccion,
                this.telefono,
                this.mail,
                this.descripcion
            ]
        );
        return result;
    }

    static async darDeBaja(idProveedor) {
        const result = await pool.execute('CALL sp_bajaProveedor( ? );', [idProveedor]);
        return result;
    }

    static async darDeAlta(idProveedor) {
        const result = await pool.execute('CALL sp_altaProveedor( ? );', [idProveedor]);
        return result;
    }

    static async buscarPorId(idProveedor) {
        const result = await pool.execute('CALL sp_buscarIdProveedor( ? );', [idProveedor]);
        return result[0][0]; 
    }

    static async listarProveedor(estado) {
        // Le pasamos el estado o NULL si queremos traer todos
        const result = await pool.execute(
            'CALL sp_listarProveedores( ? );', [estado || null]
        );
        return result[0][0]; 
    }
}

export default Proveedor;