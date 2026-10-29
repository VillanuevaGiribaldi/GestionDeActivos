import Factura from '../models/facturas.models.js';
import catchSQL45000 from '../utils/error.handler.js';

const nuevaFactura = async (req, res) => {
    try {
        const factura = Factura.fromObject(req.body.factura);
        const resultado = await factura.save();
        
        return res.status(201).json({
            mensaje: 'Factura registrada exitosamente',
            datos: resultado
        });
    } catch (error) {
        console.error('Error al registrar la factura:', error);
        catchSQL45000(res, error, "No se pudo registrar la factura");
        if (!res.headersSent) res.status(500).json({ mensaje: 'Error interno al crear la factura' });
    }
}

const getFactura = async (req, res) => {
    try {
        const facturaData = await Factura.buscarPorId(parseInt(req.params.id));
        if (!facturaData) {
            return res.status(404).json({ message: "No existe la factura indicada" });
        }
        res.status(200).json({
            factura: facturaData,
            message: "Operación exitosa"
        });
    } catch (error) {
        console.error('Error al buscar la factura:', error);
        catchSQL45000(res, error, "No se pudo encontrar la factura");
        if (!res.headersSent) res.status(500).json({ message: "Error interno al buscar la factura" });
    }
}

const listarFacturas = async (req, res) => {
    try {
        const estado = req.query.estado || null;
        if (estado !== null && !['A', 'I'].includes(estado)) {
            return res.status(400).json({ message: "Estado no válido" });
        }
        
        const result = await Factura.listarFacturas(estado);
        res.status(200).json({ 
            message: "Operación exitosa",
            facturas: result
        });
    } catch (error) {
        console.error('Error al buscar las facturas guardadas:', error);
        catchSQL45000(res, error, "No se pudo buscar las facturas");
        if (!res.headersSent) res.status(500).json({ message: "Error interno al buscar las facturas guardadas" });
    }
}

const modificarFactura = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        
        if (idUrl !== parseInt(req.body.factura.idFactura)) {
            return res.status(400).json({ message: "Los IDs de la URL y del cuerpo no se corresponden" });
        }
        
        const factura = Factura.fromObject(req.body.factura);
        await factura.modificar();
        
        return res.status(200).json({ message: "Factura modificada exitosamente" });

    } catch (error) {
        console.error('Error al modificar la factura:', error);
        if (!catchSQL45000(res, error, "No se pudo modificar la factura")) {
            return res.status(500).json({ message: "Error interno al modificar la factura" });
        }
    }
}

const bajaFactura = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        await Factura.darDeBaja(idUrl);
        return res.status(200).json({ message: "Factura dada de baja exitosamente" });
    } catch (error) {
        console.error('Error al dar de baja la factura:', error);
        catchSQL45000(res, error, "No se pudo dar de baja la factura");
        if (!res.headersSent) return res.status(500).json({ message: "Error interno al dar de baja la factura" });
    }
}

const altaFactura = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        await Factura.darDeAlta(idUrl);
        return res.status(201).json({ message: "Factura dada de alta exitosamente" });
    } catch (error) {
        console.error('Error al dar de alta la factura:', error);
        catchSQL45000(res, error, "No se pudo dar de alta la factura");
        if (!res.headersSent) res.status(500).json({ message: "Error interno al dar de alta la factura" });
    }
}

export { nuevaFactura, getFactura, listarFacturas, modificarFactura, bajaFactura, altaFactura };