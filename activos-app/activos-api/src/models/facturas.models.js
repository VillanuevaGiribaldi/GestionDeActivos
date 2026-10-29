import { pool } from "../config/mysql.js";

class Factura {
    constructor({ idFactura, idProveedor, fecha, monto, moneda, numero, ruta, estado }) {
        this.idFactura = idFactura ?? null;
        this.idProveedor = idProveedor ?? null;
        this.fecha = fecha 
            ? fecha.substring(0, 19).replace('T', ' ') 
            : null;
        this.monto = monto;
        this.moneda = moneda;
        this.numero = numero;
        this.ruta = ruta;
        this.estado = estado;
    }

    static fromObject(data) {
        return new Factura(data);
    }

    async save() {
        const result = await pool.execute(
            'CALL sp_nuevaFactura( ?, ?, ?, ?, ?, ?, ?, @pIdFactura );',
            [
                this.idProveedor, 
                this.fecha, 
                this.monto, 
                this.moneda, 
                this.numero, 
                this.ruta, 
                this.estado
            ]
        );
        return result;
    }

    async modificar() {
        const result = await pool.execute(
            'CALL sp_modificarFactura( ?, ?, ?, ?, ?, ?, ? );', 
            [
                this.idFactura,
                this.idProveedor,
                this.fecha,
                this.monto,
                this.moneda,
                this.numero,
                this.ruta
            ]
        );
        return result;
    }

    static async darDeBaja(idFactura) {
        const result = await pool.execute('CALL sp_bajaFactura( ? );', [idFactura]);
        return result;
    }

    static async darDeAlta(idFactura) {
        const result = await pool.execute('CALL sp_altaFactura( ? );', [idFactura]);
        return result;
    }

    static async buscarPorId(idFactura) {
        const result = await pool.execute('CALL sp_buscarIdFactura( ? );', [idFactura]);
        return result[0][0][0]; 
    }

    static async listarFacturas(estado) {
        const result = await pool.execute('CALL sp_listarFacturas( ? );', [estado || null]);
        return result[0][0]; 
    }
}

export default Factura;