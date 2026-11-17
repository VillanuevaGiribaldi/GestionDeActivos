import { useEffect, useState } from 'react';
import { listarMantenimientos } from '../assets/services/mantenimientoService';
import type { Mantenimiento } from '../types/mantenimiento';
import {
    Table, TableBody, TableCell, TableContainer,
    TableHead, TableRow, Paper, Chip
} from "@mui/material";

export default function Mantenimientos() {
    const [mantenimientos, setMantenimientos] = useState<Mantenimiento[]>([]);
    const [cargando, setCargando] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const fetchMantenimientos = async () => {
            try {
                const respuesta = await listarMantenimientos();
                
                if (respuesta.error) {
                    setError(respuesta.error);
                } else {
                    const dataObtenida = (respuesta as any).mantenimientos || respuesta.data || [];
                    setMantenimientos(dataObtenida);
                }
            } catch (err) {
                setError(err instanceof Error ? err.message : "Error desconocido");
            } finally {
                setCargando(false);
            }
        };

        fetchMantenimientos();
    }, []);

    if (error) return (
        <div className="p-6 text-center text-red-500 font-bold">
            Error: {error}
        </div>
    );

    return (
        <div className="p-6 space-y-6">
            <h1 className="text-3xl font-bold text-gray-800">Registro de Mantenimientos</h1>
            
            <TableContainer component={Paper} className="shadow-sm border border-gray-100">
                <Table stickyHeader size="small">
                    <TableHead>
                        <TableRow>
                            <TableCell><strong>ID</strong></TableCell>
                            <TableCell><strong>Activo</strong></TableCell>
                            <TableCell><strong>Proveedor</strong></TableCell>
                            <TableCell><strong>Falla Reportada</strong></TableCell>
                            <TableCell><strong>Envío</strong></TableCell>
                            <TableCell><strong>Costo</strong></TableCell>
                            <TableCell><strong>Estado</strong></TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {cargando ? (
                            <TableRow>
                                <TableCell colSpan={7} align="center" className="py-8">
                                    Cargando historial de reparaciones...
                                </TableCell>
                            </TableRow>
                        ) : mantenimientos.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={7} align="center" className="py-8 text-gray-500">
                                    No hay mantenimientos registrados
                                </TableCell>
                            </TableRow>
                        ) : (
                            mantenimientos.map((mant) => (
                                <TableRow 
                                    key={mant.idMantenimiento}
                                    hover
                                    style={{ cursor: 'pointer' }}
                                >
                                    <TableCell>{mant.idMantenimiento}</TableCell>
                                    <TableCell className="font-medium text-gray-900">
                                        {mant.nombreActivo} <br/>
                                        <span className="text-xs text-gray-500">{mant.numeroSerie}</span>
                                    </TableCell>
                                    <TableCell className="text-gray-600">
                                        {mant.nombreProveedor}
                                    </TableCell>
                                    <TableCell className="text-gray-600">
                                        {mant.fallaReportada}
                                    </TableCell>
                                    <TableCell className="text-gray-600">
                                        {new Date(mant.fechaEnvio).toLocaleDateString('es-AR')}
                                    </TableCell>
                                    <TableCell className="text-gray-900 font-medium">
                                        {mant.costoTotal ? `$ ${Number(mant.costoTotal).toLocaleString('es-AR')}` : "-"}
                                    </TableCell>
                                    <TableCell>
                                        <Chip 
                                            label={mant.fechaDevolucion ? 'Finalizado' : 'En Curso'} 
                                            color={mant.fechaDevolucion ? 'default' : 'warning'}
                                            size="small"
                                            variant={mant.fechaDevolucion ? 'outlined' : 'filled'}
                                        />
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