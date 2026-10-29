import Atributo from '../models/atributos.models.js';
import catchSQL45000 from '../utils/error.handler.js';

const nuevoAtributo = async (req, res) => {
    try {
        const atributo = Atributo.fromObject(req.body.atributo);
        const idAtributo = await atributo.save();

        return res.status(201).json({
            message: 'Atributo creado exitosamente',
            idAtributo
        });
    } catch (error) {
        console.error('Error al guardar el atributo:', error);
        !catchSQL45000(res, error, "No se pudo crear el atributo")
        if (!res.headersSent) res.status(500).json({ message: 'Error interno al crear el atributo' });
        
    }
};

const modificarAtributo = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        if (idUrl !== parseInt(req.body.atributo?.idAtributo)) {
            return res.status(400).json({
                message: "Los IDs de la URL y del cuerpo no se corresponden"
            });
        }

        const atributo = Atributo.fromObject(req.body.atributo);
        await atributo.modificar();

        return res.status(200).json({ message: "Atributo modificado exitosamente" });
    } catch (error) {
        console.error('Error al modificar el atributo:', error);
        !catchSQL45000(res, error, "No se pudo modificar el atributo")
        if (!res.headersSent) res.status(500).json({ message: "Error interno al modificar el atributo" });
        
    }
};

const eliminarAtributo = async (req, res) => {
    try {
        
        const atributo = Atributo.fromObject({
            idAtributo: req.params.id 
        });
        await atributo.eliminar();

        return res.status(200).json({ message: "Atributo eliminado exitosamente" });
    } catch (error) {
        console.error('Error al eliminar el atributo:', error);
        !catchSQL45000(res, error, "No se pudo eliminar el atributo")
        if (!res.headersSent) res.status(500).json({ message: "Error interno eliminar el atributo" });
        
    }
};


const getAtributo = async (req, res) => {
    try {
        const atributoData = await Atributo.buscarPorId(parseInt(req.params.id));
        if (!atributoData) {
            return res.status(404).json({ message: "No existe el atributo indicado" });
        }
        return res.status(200).json({
            atributo: atributoData,
            message: "Se encontró el atributo indicado"
        });
    } catch (error) {
        console.error('Error al buscar el atributo:', error);
        !catchSQL45000(res, error, "No se pudo encontrar el atributo")
        if (!res.headersSent) res.status(500).json({ message: "Error interno al buscar el atributo" });
        
    }
};

// GET /api/atributo                      -> todos
// GET /api/atributo?idTipo=4             -> atributos de un tipo
const listarAtributos = async (req, res) => {
    try {
              

        let idTipo = null;
        if (req.query.idTipo !== undefined && req.query.idTipo !== '') {
            idTipo = parseInt(req.query.idTipo);
            if (Number.isNaN(idTipo)) {
                return res.status(400).json({ message: "idTipo no valido" });
            }
        }

        const atributos = await Atributo.listarAtributos( idTipo);
        return res.status(200).json({
            message: "Operación exitosa",
            atributos
        });
    } catch (error) {
        console.error('Error al listar los atributos:', error);
        !catchSQL45000(res, error, "No se pudo listar los atributos")
        if (!res.headersSent) res.status(500).json({ message: "Error interno al listar los atributos" });
        
    }
};

export { nuevoAtributo, modificarAtributo, eliminarAtributo  , getAtributo, listarAtributos };