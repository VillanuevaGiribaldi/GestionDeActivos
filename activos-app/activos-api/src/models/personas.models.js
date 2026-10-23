import { pool } from "../config/mysql.js";

class Persona {
    constructor({ idPersona, nombre, apellido, dni, cargo, estado }) {
        this.idPersona = idPersona;
        this.nombre = nombre;
        this.apellido = apellido;
        this.dni = dni;
        this.cargo = cargo;
        this.estado = estado;
    }

    static fromObject(data) {
        return new Persona(data);
    }

    async save() {
        // Ejecutamos el Stored Procedure de alta
        const result = await pool.execute(
            'CALL sp_nuevaPersona( ?, ?, ?, ?, ?, @pIdPersona );',
            [this.nombre, this.apellido, this.dni, this.cargo, this.estado]
        );
        return result;
    }
    static async buscarPorId(id) {
        const result = await pool.execute
        (
            'CALL sp_buscarIdPersona( ? );', [id]
        )
        console.log(result[0][0][0])
        return result[0][0][0]
    }

    static async darDeBaja(idPersona) {
        const result = await pool.execute(
            'CALL sp_bajaPersona( ? );', [idPersona]
        );
        return result;
    }
    static async darDeAlta(idPersona) {
        const result = await pool.execute(
            'CALL sp_altaPersona( ? );', [idPersona]
        );
        return result;
    }
    async modificar() {
        const result = await pool.execute
        (
            'CALL sp_modificarPersona( ?, ?, ?, ?, ? );', 
            [
                this.idPersona ,
                this.nombre,
                this.apellido,
                this.dni,
                this.cargo
            ]
        );
        return result;
    }

}

export default Persona;