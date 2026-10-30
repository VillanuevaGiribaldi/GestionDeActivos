import Mantenimiento from '../models/mantenimientos.models.js';
import catchSQL45000 from '../utils/error.handler.js';

const nuevoMantenimiento = async (req, res) => {
    try {
        const mantenimiento = Mantenimiento.fromObject(req.body.mantenimiento);
        // El usuario responsable sale del token JWT (lo setea authDefault)
        const idMantenimiento = await mantenimiento.save(req.usuario.id);

        return res.status(201).json({
            message: 'Mantenimiento registrado exitosamente',
            idMantenimiento
        });
    } catch (error) {
        console.error('Error al registrar el mantenimiento:', error);
        if (!catchSQL45000(res, error, "No se pudo registrar el mantenimiento")) {
            return res.status(500).json({ message: 'Error interno al registrar el mantenimiento' });
        }
    }
};

const getMantenimiento = async (req, res) => {
    try {
        const data = await Mantenimiento.buscarPorId(parseInt(req.params.id));
        if (!data) {
            return res.status(404).json({ message: "No existe el mantenimiento indicado" });
        }
        return res.status(200).json({
            mantenimiento: data,
            message: "Se encontró el mantenimiento indicado"
        });
    } catch (error) {
        console.error('Error al buscar el mantenimiento:', error);
        if (!catchSQL45000(res, error, "No se pudo encontrar el mantenimiento")) {
            return res.status(500).json({ message: "Error interno al buscar el mantenimiento" });
        }
    }
};

// GET /api/mantenimiento?estado=A&idActivo=3
const listarMantenimientos = async (req, res) => {
    try {
        const estado = req.query.estado || null;
        if (estado !== null && !['A', 'I'].includes(estado)) {
            return res.status(400).json({ message: "Estado no válido" });
        }
        const idActivo = req.query.idActivo ? parseInt(req.query.idActivo) : null;

        const mantenimientos = await Mantenimiento.listarMantenimientos(estado, idActivo);
        return res.status(200).json({
            message: "Operación exitosa",
            mantenimientos
        });
    } catch (error) {
        console.error('Error al listar los mantenimientos:', error);
        if (!catchSQL45000(res, error, "No se pudo listar los mantenimientos")) {
            return res.status(500).json({ message: "Error interno al listar los mantenimientos" });
        }
    }
};

const modificarMantenimiento = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        if (idUrl !== parseInt(req.body.mantenimiento?.idMantenimiento)) {
            return res.status(400).json({ message: "Los IDs de la URL y del cuerpo no se corresponden" });
        }

        const mantenimiento = Mantenimiento.fromObject(req.body.mantenimiento);
        await mantenimiento.modificar();

        return res.status(200).json({ message: "Mantenimiento modificado exitosamente" });
    } catch (error) {
        console.error('Error al modificar el mantenimiento:', error);
        if (!catchSQL45000(res, error, "No se pudo modificar el mantenimiento")) {
            return res.status(500).json({ message: "Error interno al modificar el mantenimiento" });
        }
    }
};

// PUT /api/mantenimiento/:id/fin  -> cierra el mantenimiento y actualiza estado del activo
const finMantenimiento = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        const mantenimiento = Mantenimiento.fromObject({
            ...req.body.mantenimiento,
            idMantenimiento: idUrl
        });
        await mantenimiento.finalizar(req.usuario.id);

        return res.status(200).json({ message: "Mantenimiento finalizado exitosamente" });
    } catch (error) {
        console.error('Error al finalizar el mantenimiento:', error);
        if (!catchSQL45000(res, error, "No se pudo finalizar el mantenimiento")) {
            return res.status(500).json({ message: "Error interno al finalizar el mantenimiento" });
        }
    }
};

const bajaMantenimiento = async (req, res) => {
    try {
        await Mantenimiento.darDeBaja(parseInt(req.params.id));
        return res.status(200).json({ message: "Mantenimiento dado de baja exitosamente" });
    } catch (error) {
        console.error('Error al dar de baja el mantenimiento:', error);
        if (!catchSQL45000(res, error, "No se pudo dar de baja el mantenimiento")) {
            return res.status(500).json({ message: "Error interno al dar de baja el mantenimiento" });
        }
    }
};

const altaMantenimiento = async (req, res) => {
    try {
        await Mantenimiento.darDeAlta(parseInt(req.params.id));
        return res.status(200).json({ message: "Mantenimiento dado de alta exitosamente" });
    } catch (error) {
        console.error('Error al dar de alta el mantenimiento:', error);
        if (!catchSQL45000(res, error, "No se pudo dar de alta el mantenimiento")) {
            return res.status(500).json({ message: "Error interno al dar de alta el mantenimiento" });
        }
    }
};

export {
    nuevoMantenimiento,
    getMantenimiento,
    listarMantenimientos,
    modificarMantenimiento,
    finMantenimiento,
    bajaMantenimiento,
    altaMantenimiento
};