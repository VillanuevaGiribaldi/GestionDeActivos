import Proveedor from '../models/proveedores.models.js';
import catchSQL45000 from '../utils/error.handler.js';

const nuevoProveedor = async (req, res) => {
    try {
        const proveedor = Proveedor.fromObject(req.body.proveedor);
        const resultado = await proveedor.save();
        
        return res.status(201).json({
            mensaje: 'Proveedor creado exitosamente',
            datos: resultado
        });
    } catch (error) {
        console.error('Error al guardar el proveedor:', error);
        catchSQL45000(res, error, "No se pudo crear el proveedor");
        return res.status(500).json({
            mensaje: 'Error interno al crear el proveedor'
        });
    }
}

const getProveedor = async (req, res) => {
    try {
        const proveedorData = await Proveedor.buscarPorId(parseInt(req.params.id));
        if (!proveedorData) {
            return res.status(404).json({ message: "No existe el proveedor indicado" });
        }
        res.status(200).json({
            proveedor: proveedorData,
            message: "Se encontró el proveedor indicado"
        });
    } catch (error) {
        console.error('Error al buscar el proveedor:', error);
        catchSQL45000(res, error, "No se pudo encontrar el proveedor");
        res.status(500).json({ message: "Error interno al buscar el proveedor" });
    }
}

const listarProveedores = async (req, res) => {
    try {
        const estado = req.query.estado || null;
        if (estado !== null && !['A', 'I'].includes(estado)) {
            return res.status(400).json({
                message: "Estado no valido"
            });
        }
        // Llama a listarProveedor() tal cual lo nombraste en tu modelo
        const result = await Proveedor.listarProveedor(estado);
        res.status(200).json({ 
            message: "Operación exitosa",
            proveedores: result
         });
    } catch (error) {
        console.error('Error al buscar los proveedores guardados:', error);
        catchSQL45000(res, error, "No se pudo buscar los proveedores guardados");
        if (!res.headersSent) {
            res.status(500).json({ message: "Error interno al buscar los proveedores guardados" });
        }
    }
}

const modificarProveedor = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        
        if (idUrl !== parseInt(req.body.proveedor.idProveedor)) {
            return res.status(400).json({ message: "Los IDs de la URL y del cuerpo no se corresponden" });
        }
        
        const proveedor = Proveedor.fromObject(req.body.proveedor);
        await proveedor.modificar();
        
        return res.status(200).json({ message: "Proveedor modificado exitosamente" });

    } catch (error) {
        console.error('Error al modificar el proveedor:', error);
        if (!catchSQL45000(res, error, "No se pudo modificar el proveedor")) {
            return res.status(500).json({ message: "Error interno al modificar el proveedor" });
        }
    }
}

const bajaProveedor = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        await Proveedor.darDeBaja(idUrl);
        return res.status(200).json({ message: "Proveedor dado de baja exitosamente" });
    } catch (error) {
        console.error('Error al dar de baja el proveedor:', error);
        catchSQL45000(res, error, "No se pudo dar de baja el proveedor");
        return res.status(500).json({ message: "Error interno al dar de baja el proveedor" });
    }
}

const altaProveedor = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        await Proveedor.darDeAlta(idUrl);
        return res.status(201).json({ message: "Proveedor dado de alta exitosamente" });
    } catch (error) {
        console.error('Error al dar de alta el proveedor:', error);
        catchSQL45000(res, error, "No se pudo dar de alta el proveedor");
        res.status(500).json({ message: "Error interno al dar de alta el proveedor" });
    }
}

export { nuevoProveedor, getProveedor, listarProveedores, modificarProveedor, bajaProveedor, altaProveedor };