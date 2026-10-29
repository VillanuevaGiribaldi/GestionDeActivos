import Imagen from '../models/imagenes.models.js';
import catchSQL45000 from '../utils/error.handler.js';

const nuevaImagen = async (req, res) => {
    try {
        const imagen = Imagen.fromObject(req.body.imagen);
        const resultado = await imagen.save();
        
        return res.status(201).json({
            mensaje: 'Imagen registrada exitosamente',
            datos: resultado
        });
    } catch (error) {
        console.error('Error al registrar la imagen:', error);
        catchSQL45000(res, error, "No se pudo registrar la imagen");
        if (!res.headersSent) res.status(500).json({ mensaje: 'Error interno al crear la imagen' });
    }
}

const getImagen = async (req, res) => {
    try {
        const imagenData = await Imagen.buscarPorId(parseInt(req.params.id));
        if (!imagenData) {
            return res.status(404).json({ message: "No existe la imagen indicada" });
        }
        res.status(200).json({
            imagen: imagenData,
            message: "Operación exitosa"
        });
    } catch (error) {
        console.error('Error al buscar la imagen:', error);
        catchSQL45000(res, error, "No se pudo encontrar la imagen");
        if (!res.headersSent) res.status(500).json({ message: "Error interno al buscar la imagen" });
    }
}

const listarImagenes = async (req, res) => {
    try {
        const estado = req.query.estado || null;
        const idActivo = req.query.idActivo ? parseInt(req.query.idActivo) : null;
        
        if (estado !== null && !['A', 'I'].includes(estado)) {
            return res.status(400).json({ message: "Estado no válido" });
        }
        
        const result = await Imagen.listarImagenes(estado, idActivo);
        res.status(200).json({ 
            message: "Operación exitosa",
            imagenes: result
        });
    } catch (error) {
        console.error('Error al buscar las imágenes:', error);
        catchSQL45000(res, error, "No se pudo buscar las imágenes");
        if (!res.headersSent) res.status(500).json({ message: "Error interno al buscar las imágenes" });
    }
}

const modificarImagen = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        
        if (idUrl !== parseInt(req.body.imagen.idImagen)) {
            return res.status(400).json({ message: "Los IDs de la URL y del cuerpo no se corresponden" });
        }
        
        const imagen = Imagen.fromObject(req.body.imagen);
        await imagen.modificar();
        
        return res.status(200).json({ message: "Imagen modificada exitosamente" });

    } catch (error) {
        console.error('Error al modificar la imagen:', error);
        if (!catchSQL45000(res, error, "No se pudo modificar la imagen")) {
            return res.status(500).json({ message: "Error interno al modificar la imagen" });
        }
    }
}

const bajaImagen = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        await Imagen.darDeBaja(idUrl);
        return res.status(200).json({ message: "Imagen dada de baja exitosamente" });
    } catch (error) {
        console.error('Error al dar de baja la imagen:', error);
        catchSQL45000(res, error, "No se pudo dar de baja la imagen");
        if (!res.headersSent) return res.status(500).json({ message: "Error interno al dar de baja la imagen" });
    }
}

const altaImagen = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        await Imagen.darDeAlta(idUrl);
        return res.status(201).json({ message: "Imagen dada de alta exitosamente" });
    } catch (error) {
        console.error('Error al dar de alta la imagen:', error);
        catchSQL45000(res, error, "No se pudo dar de alta la imagen");
        if (!res.headersSent) res.status(500).json({ message: "Error interno al dar de alta la imagen" });
    }
}

export { nuevaImagen, getImagen, listarImagenes, modificarImagen, bajaImagen, altaImagen };