import Tipo from '../models/tipos.models.js';
import catchSQL45000 from '../utils/error.handler.js';

const nuevoTipo = async (req, res) => {
    try {
        const tipo = Tipo.fromObject(req.body.tipo);
        const idTipo = await tipo.save();

        return res.status(201).json({
            message: 'Tipo creado exitosamente',
            idTipo: idTipo
        });
    } catch (error) {
        console.error('Error al guardar el tipo:', error);
        if (!catchSQL45000(res, error, "No se pudo crear el tipo")) {
            return res.status(500).json({
                message: 'Error interno al crear el tipo'
            });
        }
    }
};

const modificarTipo = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        if (idUrl !== parseInt(req.body.tipo?.idTipo)) {
            return res.status(400).json({
                message: "Los IDs de la URL y del cuerpo no se corresponden"
            });
        }

        const tipo = Tipo.fromObject(req.body.tipo);
        await tipo.modificar();

        return res.status(200).json({
            message: "Tipo modificado exitosamente"
        });
    } catch (error) {
        console.error('Error al modificar el tipo:', error);
        if (!catchSQL45000(res, error, "No se pudo modificar el tipo")) {
            return res.status(500).json({
                message: "Error interno al modificar el tipo"
            });
        }
    }
};

const bajaTipo = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        await Tipo.darDeBaja(idUrl);

        return res.status(200).json({
            message: "Tipo dado de baja exitosamente"
        });
    } catch (error) {
        console.error('Error al dar de baja el tipo:', error);
        if (!catchSQL45000(res, error, "No se pudo dar de baja el tipo")) {
            return res.status(500).json({
                message: "Error interno al dar de baja el tipo"
            });
        }
    }
};

const altaTipo = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        await Tipo.darDeAlta(idUrl);

        return res.status(200).json({
            message: "Tipo dado de alta exitosamente"
        });
    } catch (error) {
        console.error('Error al dar de alta el tipo:', error);
        if (!catchSQL45000(res, error, "No se pudo dar de alta el tipo")) {
            return res.status(500).json({
                message: "Error interno al dar de alta el tipo"
            });
        }
    }
};

const getTipo = async (req, res) => {
    try {
        const tipoData = await Tipo.buscarPorId(parseInt(req.params.id));
        if (!tipoData) {
            return res.status(404).json({
                message: "No existe el tipo indicado"
            });
        }
        return res.status(200).json({
            tipo: tipoData,
            message: "Se encontró el tipo indicado"
        });
    } catch (error) {
        console.error('Error al buscar el tipo:', error);
        if (!catchSQL45000(res, error, "No se pudo encontrar el tipo")) {
            return res.status(500).json({
                message: "Error interno al buscar el tipo"
            });
        }
    }
};

// GET /api/tipo?estado=A  -> solo activos
// GET /api/tipo?estado=I  -> solo inactivos
// GET /api/tipo           -> todos
const listarTipos = async (req, res) => {
    try {
        const estado = req.query.estado || null;
        if (estado !== null && !['A', 'I'].includes(estado)) {
            return res.status(400).json({
                message: "Estado no valido"
            });
        }

        const tipos = await Tipo.listarTipos(estado);
        return res.status(200).json({
            message: "Operación exitosa",
            tipos: tipos
        });
    } catch (error) {
        console.error('Error al listar los tipos:', error);
        if (!catchSQL45000(res, error, "No se pudo listar los tipos")) {
            return res.status(500).json({
                message: "Error interno al listar los tipos"
            });
        }
    }
};

export { nuevoTipo, modificarTipo, bajaTipo, altaTipo, getTipo, listarTipos };