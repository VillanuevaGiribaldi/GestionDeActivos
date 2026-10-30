import { pool } from "../config/mysql.js";

class Activo {
    constructor({ 
        idActivo, idMarca, idUbicacion, idTipo, idEstado, 
        idFactura, idPersona, compone, nombre, fechaRegistro, 
        valoresAtributos, precioUnitario, numeroSerie, modelo 
    }) {
        this.idActivo = idActivo ?? null;
        this.idMarca = idMarca;
        this.idUbicacion = idUbicacion;
        this.idTipo = idTipo;
        this.idEstado = idEstado;
        this.idFactura = idFactura ?? null;
        this.idPersona = idPersona ?? null;
        this.compone = compone ?? null;
        this.nombre = nombre;
        this.fechaRegistro = fechaRegistro ?? null;
        
        // El frontend envía un objeto llave/valor { "1": "16GB", "2": "Core i7" }.
        // Si viene como string, lo parseamos. Si ya es objeto, lo dejamos igual.
        this.valoresAtributos = (typeof valoresAtributos === 'string') 
            ? JSON.parse(valoresAtributos) 
            : (valoresAtributos || {});
            
        this.precioUnitario = precioUnitario;
        this.numeroSerie = numeroSerie;
        this.modelo = modelo;
    }

    static fromObject(data) {
        return new Activo(data);
    }

    async save(idUsuarioModificador) {
        // Ejecutamos el SP que inserta en Activos y distribuye el JSON en la tabla Valores
        const result = await pool.execute(
            `CALL sp_nuevoActivo( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? );`,
            [
                idUsuarioModificador, // Extraído del JWT
                this.idMarca,
                this.idUbicacion,
                this.idTipo,
                this.idEstado,
                this.idFactura,
                this.idPersona,
                this.compone,
                this.nombre,
                JSON.stringify(this.valoresAtributos), // Pasamos el JSON como String a MySQL
                this.precioUnitario,
                this.numeroSerie,
                this.modelo
            ]
        );
        return result;
    }

    async modificar(idUsuarioModificador) {
        const result = await pool.execute(
            `CALL sp_modificarActivo( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? );`, 
            [
                this.idActivo,
                idUsuarioModificador, // Extraído del JWT
                this.idMarca,
                this.idUbicacion,
                this.idTipo,
                this.idEstado,
                this.idFactura,
                this.idPersona,
                this.compone,
                this.nombre,
                JSON.stringify(this.valoresAtributos),
                this.precioUnitario,
                this.numeroSerie,
                this.modelo
            ]
        );
        return result;
    }

    static async darDeBaja(idActivo, idEstadoBaja, idUsuarioModificador, comentario) {
        const result = await pool.execute(
            'CALL sp_darDeBajaActivo( ?, ?, ?, ? );', 
            [idActivo, idEstadoBaja, idUsuarioModificador, comentario]
        );
        return result;
    }

    static async buscarPorId(idActivo) {
        // sp_obtenerDetalleActivo empaqueta la tabla Valores de vuelta a un JSON
        const result = await pool.execute('CALL sp_obtenerDetalleActivo( ? );', [idActivo]);
        return result[0][0][0]; 
    }

    static async listarAvanzado(filtros) {
        const { 
            filtroTexto, idTipo, idMarca, idUbicacion, idEstado, 
            idPersona, atributoClave, atributoValor, 
            ordenColumna, ordenDireccion, limit, offset 
        } = filtros;

        const result = await pool.execute(
            `CALL sp_buscarActivosAvanzado( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? );`, 
            [
                filtroTexto || null,
                idTipo || null,
                idMarca || null,
                idUbicacion || null,
                idEstado || null,
                idPersona || null,
                atributoClave || null, // Clave de la tabla Valores
                atributoValor || null, // Valor en la tabla Valores
                ordenColumna || null,
                ordenDireccion || null,
                limit ? parseInt(limit) : 50,
                offset ? parseInt(offset) : 0
            ]
        );
        return result[0][0]; 
    }
}

export default Activo;