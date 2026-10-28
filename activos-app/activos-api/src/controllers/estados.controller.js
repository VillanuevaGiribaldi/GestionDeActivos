import Estado from '../models/estados.models.js';
import catchSQL45000 from '../utils/error.handler.js';

const nuevoEstado = async (req, res) => {
    try {
        const estado = Estado.fromObject(req.body.estado);
        const idEstado = await estado.save();

        return res.status(201).json({
            message: 'Estado creado exitosamente',
            idEstado
        });
    } catch (error) {
        console.error('Error al guardar el estado:', error);
        if (!catchSQL45000(res, error, "No se pudo crear el estado")) {
            return res.status(500).json({
                message: 'Error interno al crear el estado'
            });
        }
    }
};

const getEstado = async (req, res) => {
    try {
        const estadoData = await Estado.buscarPorId(parseInt(req.params.id));
        if (!estadoData) {
            return res.status(404).json({
                message: "No existe el estado indicado"
            });
        }
        return res.status(200).json({
            estado: estadoData,
            message: "Se encontró el estado indicado"
        });
    } catch (error) {
        console.error('Error al buscar el estado:', error);
        if (!catchSQL45000(res, error, "No se pudo encontrar el estado")) {
            return res.status(500).json({
                message: "Error interno al buscar el estado"
            });
        }
    }
};

const modificarEstado = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        if (idUrl !== parseInt(req.body.estado?.idEstado)) {
            return res.status(400).json({
                message: "Los IDs de la URL y del cuerpo no se corresponden"
            });
        }

        const estado = Estado.fromObject(req.body.estado);
        await estado.modificar();

        return res.status(200).json({
            message: "Estado modificado exitosamente"
        });
    } catch (error) {
        console.error('Error al modificar el estado:', error);
        if (!catchSQL45000(res, error, "No se pudo modificar el estado")) {
            return res.status(500).json({
                message: "Error interno al modificar el estado"
            });
        }
    }
};

const bajaEstado = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        await Estado.darDeBaja(idUrl);
        return res.status(200).json({ message: "Estado dado de baja exitosamente" });
    } catch (error) {
        console.error('Error al dar de baja el estado:', error);
        if (!catchSQL45000(res, error, "No se pudo dar de baja el estado")) {
            return res.status(500).json({ message: "Error interno al dar de baja el estado" });
        }
    }
};

const altaEstado = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        await Estado.darDeAlta(idUrl);
        return res.status(200).json({ message: "Estado dado de alta exitosamente" });
    } catch (error) {
        console.error('Error al dar de alta el estado:', error);
        if (!catchSQL45000(res, error, "No se pudo dar de alta el estado")) {
            return res.status(500).json({ message: "Error interno al dar de alta el estado" });
        }
    }
};

// GET /api/estado            -> todos
// GET /api/estado?estado=A   -> solo activos
const listarEstados = async (req, res) => {
    try {
        const filtro = req.query.estado || null;
        const estados = await Estado.listarEstados(filtro);
        return res.status(200).json({
            message: "Operación exitosa",
            estados
        });
    } catch (error) {
        console.error('Error al listar los estados:', error);
        if (!catchSQL45000(res, error, "No se pudo listar los estados")) {
            return res.status(500).json({ message: "Error interno al listar los estados" });
        }
    }
};

export { nuevoEstado, getEstado, modificarEstado, bajaEstado, altaEstado, listarEstados };