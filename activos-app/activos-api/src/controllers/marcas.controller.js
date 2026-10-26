import Marca from '../models/marcas.models.js';
import catchSQL45000 from '../utils/error.handler.js';

const nuevaMarca = async (req, res) => {
    try {
        const marca = Marca.fromObject(req.body.marca);
        const resultado = await marca.save();
        
        return res.status(201).json({
            mensaje: 'Marca creada exitosamente',
            datos: resultado
        });
    } catch (error) {
        console.error('Error al guardar la marca:', error);
        catchSQL45000(res, error, "No se pudo crear la marca");
        return res.status(500).json({
            mensaje: 'Error interno al crear la marca'
        });
    }
}

const getMarca = async (req, res) => {
    try {
        const marcaData = await Marca.buscarPorId(parseInt(req.params.id));
        if (!marcaData) {
            return res.status(404).json({
                message: "No existe la marca indicada"
            });
        }
        res.status(200).json({
            marca: marcaData,
            message: "Se encontró la marca indicada"
        });
    } catch (error) {
        catchSQL45000(res, error, "No se pudo encontrar la marca");
        res.status(500).json({
            message: "Error interno al buscar la marca"
        });
    }
}

const modificarMarca = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        if (idUrl !== parseInt(req.body.marca.idMarca)) {
            return res.status(400).json({
                message: "Los IDs de la URL y del cuerpo no se corresponden"
            });
        }
        
        const marca = Marca.fromObject(req.body.marca);
        await marca.modificar();
        
        return res.status(200).json({
            message: "Marca modificada exitosamente"
        });
    } catch (error) {
        console.error('Error al modificar la marca:', error);
        if (!catchSQL45000(res, error, "No se pudo modificar la marca")) {
            return res.status(500).json({
                message: "Error interno al modificar la marca"
            });
        }
    }
}

const bajaMarca = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        await Marca.darDeBaja(idUrl);
        return res.status(200).json({ message: "Marca dada de baja exitosamente" });
    } catch (error) {
        console.error('Error al dar de baja la marca:', error);
        catchSQL45000(res, error, "No se pudo dar de baja la marca");
        return res.status(500).json({ message: "Error interno al dar de baja la marca" });
    }
}

const altaMarca = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        await Marca.darDeAlta(idUrl);
        return res.status(201).json({ message: "Marca dada de alta exitosamente" });
    } catch (error) {
        console.error('Error al dar de alta la marca:', error);
        catchSQL45000(res, error, "No se pudo dar de alta la marca");
        res.status(500).json({ message: "Error interno al dar de alta la marca" });
    }
}


const listarMarcas = async (req,res) => {
    try {
        const estado = req.query.estado || null;
        if (estado !== null && !['A', 'I'].includes(estado)) {
            return res.status(400).json({
                message: "Estado no valido"
            });
        }
        const result = await Marca.listarMarcas(estado)
        res.status(200).json({ message: "operación exitosa",
            marcas: result
         });
    } catch (error) {
        console.error('Error al buscar las marcas guardadas:', error);
        catchSQL45000(res, error, "No se pudo buscar las marcas guardadas");
        res.status(500).json({ message: "Error interno al buscar las marcas guardadas" });
    }
}
export { nuevaMarca, getMarca, modificarMarca, bajaMarca, altaMarca, listarMarcas };