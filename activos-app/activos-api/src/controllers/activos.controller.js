import Activo from '../models/activos.models.js';
import catchSQL45000 from '../utils/error.handler.js';

const nuevoActivo = async (req, res) => {
    try {
        const idUsuario = req.usuario.id; // Del middleware authDefault
        
        const activo = Activo.fromObject(req.body.activo);
        const resultado = await activo.save(idUsuario);
        
        // MySQL devuelve el row modificado o el OUT dependiendo de tu implementación del SP
        const idGenerado = resultado[0][0]?.[0]?.idActivo || 'Generado';

        return res.status(201).json({
            message: 'Activo registrado exitosamente',
            idActivo: idGenerado
        });
    } catch (error) {
        console.error('Error al registrar el activo:', error);
        if (!catchSQL45000(res, error, "No se pudo registrar el activo")) {
            return res.status(500).json({ message: 'Error interno al crear el activo' });
        }
    }
}

const getActivo = async (req, res) => {
    try {
        const activoData = await Activo.buscarPorId(parseInt(req.params.id));
        if (!activoData) {
            return res.status(404).json({ message: "No existe el activo indicado" });
        }
        res.status(200).json({
            activo: activoData,
            message: "Operación exitosa"
        });
    } catch (error) {
        console.error('Error al buscar el activo:', error);
        catchSQL45000(res, error, "No se pudo encontrar el activo");
        if (!res.headersSent) res.status(500).json({ message: "Error interno al buscar el activo" });
    }
}

const listarActivos = async (req, res) => {
    try {
        const result = await Activo.listarAvanzado(req.query);
        
        res.status(200).json({ 
            message: "Operación exitosa",
            activos: result
        });
    } catch (error) {
        console.error('Error al listar los activos:', error);
        catchSQL45000(res, error, "No se pudo listar los activos");
        if (!res.headersSent) res.status(500).json({ message: "Error interno al listar los activos" });
    }
}

const modificarActivo = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        const idUsuario = req.usuario.id;
        
        if (idUrl !== parseInt(req.body.activo.idActivo)) {
            return res.status(400).json({ message: "Los IDs de la URL y del cuerpo no se corresponden" });
        }
        
        const activo = Activo.fromObject(req.body.activo);
        await activo.modificar(idUsuario);
        
        return res.status(200).json({ message: "Activo modificado exitosamente" });

    } catch (error) {
        console.error('Error al modificar el activo:', error);
        if (!catchSQL45000(res, error, "No se pudo modificar el activo")) {
            return res.status(500).json({ message: "Error interno al modificar el activo" });
        }
    }
}

const bajaActivo = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        const idUsuario = req.usuario.id;
        const idEstadoBaja = parseInt(req.body.idEstadoBaja); 
        const comentario = req.body.comentario || 'Baja lógica del sistema';
        
        if (!idEstadoBaja) {
            return res.status(400).json({ message: "Debe indicar un estado de baja (idEstadoBaja) en el cuerpo de la petición" });
        }

        await Activo.darDeBaja(idUrl, idEstadoBaja, idUsuario, comentario);
        return res.status(200).json({ message: "Activo dado de baja exitosamente" });
    } catch (error) {
        console.error('Error al dar de baja el activo:', error);
        if (!catchSQL45000(res, error, "No se pudo dar de baja el activo")) {
            return res.status(500).json({ message: "Error interno al dar de baja el activo" });
        }
    }
}

export { nuevoActivo, getActivo, listarActivos, modificarActivo, bajaActivo };
