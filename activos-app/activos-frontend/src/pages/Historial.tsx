import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { listarHistorial } from '../assets/services/historialService';
import type { Historial as HistorialType } from '../types/historial';
import {
    Table, TableBody, TableCell, TableContainer,
    TableHead, TableRow, Paper, Chip, TextField, Button, Alert
} from "@mui/material";

const colorAccion = (accion: string): "success" | "info" | "error" | "warning" | "default" => {
    const a = accion.toLowerCase();
    if (a.includes("alta")) return "success";
    if (a.includes("modificaci")) return "info";
    if (a.includes("baja")) return "error";
    if (a.includes("reparaci")) return "warning";
    return "default";
};

export default function Historial() {
    const [historial, setHistorial] = useState<HistorialType[]>([]);
    const [cargando, setCargando] = useState(true);
    const [error, setError] = useState<string | null>(null);

    // Estados para el rango de fechas
    const [fechaInicio, setFechaInicio] = useState('');
    const [fechaFin, setFechaFin] = useState('');

    const navigate = useNavigate();

    const fetchHistorial = async (inicio?: string, fin?: string) => {
        setCargando(true);
        setError(null);
        try {
            const params: Record<string, string> = {};
            if (inicio) params.fechaInicio = inicio;
            if (fin) params.fechaFin = fin;

            const respuesta = await listarHistorial(
                Object.keys(params).length > 0 ? params : undefined
            );

            if (respuesta.error) {
                setError(respuesta.error);
                setHistorial([]);
            } else {
                const dataObtenida = (respuesta as any).historial || respuesta.data || [];
                setHistorial(dataObtenida);
            }
        } catch (err) {
            setError(err instanceof Error ? err.message : "Error desconocido");
            setHistorial([]);
        } finally {
            setCargando(false);
        }
    };

    // Carga inicial sin filtros (trae todo el historial)
    useEffect(() => {
        fetchHistorial();
    }, []);

    const handleFiltrar = (e: React.FormEvent) => {
        e.preventDefault();
        fetchHistorial(fechaInicio, fechaFin);
    };

    const handleLimpiar = () => {
        setFechaInicio('');
        setFechaFin('');
        fetchHistorial();
    };

    return (
        <div className="p-6 space-y-6">
            <h1 className="text-3xl font-bold text-gray-800">Historial de Movimientos</h1>

            {/* Barra de Filtros por Fecha */}
            <Paper component="form" onSubmit={handleFiltrar} className="p-4 flex flex-wrap items-center gap-4 shadow-sm border border-gray-100">
                <TextField
                    label="Desde"
                    type="date"
                    size="small"
                    value={fechaInicio}
                    onChange={(e) => setFechaInicio(e.target.value)}
                    slotProps={{ inputLabel: { shrink: true } }}
                />
                <TextField
                    label="Hasta"
                    type="date"
                    size="small"
                    value={fechaFin}
                    onChange={(e) => setFechaFin(e.target.value)}
                    slotProps={{ inputLabel: { shrink: true } }}
                />
                <Button type="submit" variant="contained" size="medium">
                    Filtrar
                </Button>
                {(fechaInicio || fechaFin) && (
                    <Button type="button" variant="outlined" color="inherit" size="medium" onClick={handleLimpiar}>
                        Limpiar
                    </Button>
                )}
            </Paper>

            {error && (
                <Alert severity="error" onClose={() => setError(null)}>
                    {error}
                </Alert>
            )}

            <TableContainer component={Paper} className="shadow-sm border border-gray-100">
                <Table stickyHeader size="small">
                    <TableHead>
                        <TableRow>
                            <TableCell><strong>Fecha</strong></TableCell>
                            <TableCell><strong>Activo</strong></TableCell>
                            <TableCell><strong>Acción</strong></TableCell>
                            <TableCell><strong>Responsable</strong></TableCell>
                            <TableCell><strong>Comentario</strong></TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {cargando ? (
                            <TableRow>
                                <TableCell colSpan={5} align="center" className="py-8">
                                    Cargando historial...
                                </TableCell>
                            </TableRow>
                        ) : historial.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={5} align="center" className="py-8 text-gray-500">
                                    No hay movimientos registrados para el rango seleccionado
                                </TableCell>
                            </TableRow>
                        ) : (
                            historial.map((item) => (
                                <TableRow
                                    key={item.idHistorial}
                                    hover
                                    onClick={() => navigate(`/activo/${item.idActivo}`)}
                                    style={{ cursor: 'pointer' }}
                                >
                                    <TableCell className="text-gray-600 whitespace-nowrap">
                                        {new Date(item.fecha).toLocaleString('es-AR', {
                                            dateStyle: 'short',
                                            timeStyle: 'short'
                                        })}
                                    </TableCell>
                                    <TableCell className="font-medium text-gray-900">
                                        {item.nombreActivo}
                                        {item.numeroSerie && (
                                            <span className="block text-xs text-gray-500">
                                                {item.numeroSerie}
                                            </span>
                                        )}
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
                            ))
                        )}
                    </TableBody>
                </Table>
            </TableContainer>
        </div>
    );
}