import Historial from '../models/historial.models.js';
import catchSQL45000 from '../utils/error.handler.js';

const listarHistorial = async (req, res) => {
    try {
        const { fechaInicio, fechaFin } = req.query;
        const result = await Historial.listarHistorial(fechaInicio, fechaFin);

        return res.status(200).json({
            historial: result,
            message: "Historial obtenido exitosamente"
        });
    } catch (error) {
        console.error('Error al listar el historial:', error);
        catchSQL45000(res, error, "No se pudo obtener el historial");
        if (!res.headersSent) {
            return res.status(500).json({ message: "Error interno al listar el historial" });
        }
    }
};

const listarHistorialActivo = async (req, res) => {
    try {
        const idActivo = parseInt(req.params.id);
        const result = await Historial.listarPorActivo(idActivo);

        return res.status(200).json({
            historial: result,
            message: "Historial del activo obtenido exitosamente"
        });
    } catch (error) {
        console.error('Error al listar el historial del activo:', error);
        catchSQL45000(res, error, "No se pudo obtener el historial del activo");
        if (!res.headersSent) {
            return res.status(500).json({ message: "Error interno al listar el historial del activo" });
        }
    }
};

export { listarHistorial, listarHistorialActivo };