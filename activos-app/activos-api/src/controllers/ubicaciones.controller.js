import Ubicacion from '../models/ubicaciones.models.js';
import catchSQL45000 from '../utils/error.handler.js';

const nuevaUbicacion = async (req, res) => {
    try {
        const ubicacion = Ubicacion.fromObject(req.body.ubicacion);
        const idUbicacion = await ubicacion.save();

        return res.status(201).json({
            message: 'Ubicación creada exitosamente',
            idUbicacion
        });
    } catch (error) {
        console.error('Error al guardar la ubicación:', error);
        if (!catchSQL45000(res, error, "No se pudo crear la ubicación")) {
            return res.status(500).json({
                message: 'Error interno al crear la ubicación'
            });
        }
    }
}

const getUbicacion = async (req, res) => {
    try {
        const ubicacionData = await Ubicacion.buscarPorId(parseInt(req.params.id));
        if (!ubicacionData) {
            return res.status(404).json({
                message: "No existe la ubicación indicada"
            });
        }
        return res.status(200).json({
            ubicacion: ubicacionData,
            message: "Se encontró la ubicación indicada"
        });
    } catch (error) {
        console.error('Error al buscar la ubicación:', error);
        if (!catchSQL45000(res, error, "No se pudo encontrar la ubicación")) {
            return res.status(500).json({
                message: "Error interno al buscar la ubicación"
            });
        }
    }
}

const modificarUbicacion = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        if (idUrl !== parseInt(req.body.ubicacion?.idUbicacion)) {
            return res.status(400).json({
                message: "Los IDs de la URL y del cuerpo no se corresponden"
            });
        }

        const ubicacion = Ubicacion.fromObject(req.body.ubicacion);
        await ubicacion.modificar();

        return res.status(200).json({
            message: "Ubicación modificada exitosamente"
        });
    } catch (error) {
        console.error('Error al modificar la ubicación:', error);
        if (!catchSQL45000(res, error, "No se pudo modificar la ubicación")) {
            return res.status(500).json({
                message: "Error interno al modificar la ubicación"
            });
        }
    }
}

const bajaUbicacion = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        await Ubicacion.darDeBaja(idUrl);
        return res.status(200).json({ message: "Ubicación dada de baja exitosamente" });
    } catch (error) {
        console.error('Error al dar de baja la ubicación:', error);
        if (!catchSQL45000(res, error, "No se pudo dar de baja la ubicación")) {
            return res.status(500).json({ message: "Error interno al dar de baja la ubicación" });
        }
    }
}

const altaUbicacion = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        await Ubicacion.darDeAlta(idUrl);
        return res.status(200).json({ message: "Ubicación dada de alta exitosamente" });
    } catch (error) {
        console.error('Error al dar de alta la ubicación:', error);
        if (!catchSQL45000(res, error, "No se pudo dar de alta la ubicación")) {
            return res.status(500).json({ message: "Error interno al dar de alta la ubicación" });
        }
    }
}

// GET /api/ubicacion?estado=

const listarUbicaciones = async (req, res) => {
    try {
        const estado = req.query?.estado || null;
        const ubicaciones = (await Ubicacion.listarUbicaciones(estado));
        return res.status(200).json({
            message: "operación exitosa",
            ubicaciones
        });
    } catch (error) {
        console.error('Error al listar las ubicaciones:', error);
        if (!catchSQL45000(res, error, "No se pudo listar las ubicaciones")) {
            return res.status(500).json({ message: "Error interno al listar las ubicaciones" });
        }
    }
}

export {
    nuevaUbicacion,
    getUbicacion,
    modificarUbicacion,
    bajaUbicacion,
    altaUbicacion,
    listarUbicaciones
};