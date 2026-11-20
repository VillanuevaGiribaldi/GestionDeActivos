import { useEffect, useState } from 'react';
import { listarHistorialActivo } from '../assets/services/historialService';
import type { Historial } from '../types/historial';
import {
    Table, TableBody, TableCell, TableContainer,
    TableHead, TableRow, Paper, Chip
} from "@mui/material";

const colorAccion = (accion: string): "success" | "info" | "error" | "warning" | "default" => {
    const a = accion.toLowerCase();
    if (a.includes("alta")) return "success";
    if (a.includes("modificaci")) return "info";
    if (a.includes("baja")) return "error";
    if (a.includes("reparaci")) return "warning";
    return "default";
};

export default function HistorialActivo({ idActivo }: { idActivo: number }) {
    const [historial, setHistorial] = useState<Historial[]>([]);
    const [cargando, setCargando] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const fetchHistorial = async () => {
            setCargando(true);
            setError(null);
            try {
                const respuesta = await listarHistorialActivo(idActivo);

                if (respuesta.error) {
                    setError(respuesta.error);
                } else {
                    const dataObtenida = (respuesta as any).historial || respuesta.data || [];
                    setHistorial(dataObtenida);
                }
            } catch (err) {
                setError(err instanceof Error ? err.message : "Error al cargar el historial");
            } finally {
                setCargando(false);
            }
        };

        if (idActivo) fetchHistorial();
    }, [idActivo]);

    if (error) return <div className="text-red-500 text-sm p-4">{error}</div>;
    if (cargando) return <div className="text-gray-500 text-sm p-4 animate-pulse">Cargando historial...</div>;
    if (historial.length === 0) return (
        <p className="vacio">Este activo no tiene movimientos registrados.</p>
    );

    return (
        <TableContainer component={Paper} variant="outlined">
            <Table size="small">
                <TableHead>
                    <TableRow>
                        <TableCell><strong>Fecha</strong></TableCell>
                        <TableCell><strong>Acción</strong></TableCell>
                        <TableCell><strong>Responsable</strong></TableCell>
                        <TableCell><strong>Comentario</strong></TableCell>
                    </TableRow>
                </TableHead>
                <TableBody>
                    {historial.map((item) => (
                        <TableRow key={item.idHistorial} hover>
                            <TableCell className="text-gray-600 whitespace-nowrap">
                                {new Date(item.fecha).toLocaleString('es-AR', {
                                    dateStyle: 'short',
                                    timeStyle: 'short'
                                })}
                            </TableCell>
                            <TableCell>
                                <Chip
                                    label={item.accionRealizada}
                                    color={colorAccion(item.accionRealizada)}
                                    size="small"
                                    variant="filled"
                                />
                            </TableCell>
                            <TableCell className="text-gray-600">
                                {item.responsable}
                                <span className="block text-xs text-gray-400">
                                    @{item.usuario}
                                </span>
                            </TableCell>
                            <TableCell className="text-gray-600">
                                {item.comentario || "-"}
                            </TableCell>
                        </TableRow>
                    ))}
                </TableBody>
            </Table>
        </TableContainer>
    );
}