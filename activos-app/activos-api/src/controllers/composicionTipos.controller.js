import ComposicionTipo from '../models/composicionTipos.models.js';
import catchSQL45000 from '../utils/error.handler.js';

const nuevaComposicion = async (req, res) => {
    try {
        const composicion = ComposicionTipo.fromObject(req.body.composicion);
        await composicion.save();
        
        return res.status(201).json({
            mensaje: 'Composición registrada exitosamente'
        });
    } catch (error) {
        console.error('Error al crear la composición:', error);
        catchSQL45000(res, error, "No se pudo crear la composición");
        if (!res.headersSent) res.status(500).json({ mensaje: 'Error interno al registrar la composición' });
    }
}

const getComponentesPermitidos = async (req, res) => {
    try {
        const idTipoPadre = parseInt(req.params.idTipoPadre);
        const componentes = await ComposicionTipo.listarComponentesDe(idTipoPadre);
        
        res.status(200).json({
            componentes: componentes,
            message: "Listado obtenido exitosamente"
        });
    } catch (error) {
        console.error('Error al listar las composiciones:', error);
        res.status(500).json({ message: "Error interno al buscar los componentes" });
    }
}

const eliminarComposicion = async (req, res) => {
    try {
        const idPadre = parseInt(req.params.idTipoPadre);
        const idComponente = parseInt(req.params.idTipoComponente);
        
        await ComposicionTipo.eliminar(idPadre, idComponente);
        
        return res.status(200).json({ message: "Composición eliminada exitosamente" });
    } catch (error) {
        console.error('Error al eliminar la composición:', error);
        catchSQL45000(res, error, "No se pudo eliminar la composición");
        if (!res.headersSent) return res.status(500).json({ message: "Error interno al eliminar la composición" });
    }
}

export { nuevaComposicion, getComponentesPermitidos, eliminarComposicion };