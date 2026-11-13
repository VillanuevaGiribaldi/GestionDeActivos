import { useEffect, useState } from 'react';
import { getUbicaciones } from '../assets/services/ubicacionService';
import type { Ubicacion } from '../types/ubicacion';
import {
    Table, TableBody, TableCell, TableContainer,
    TableHead, TableRow, Paper, Chip
} from "@mui/material";

export default function Ubicaciones() {
    const [ubicaciones, setUbicaciones] = useState<Ubicacion[]>([]);
    const [cargando, setCargando] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const fetchUbicaciones = async () => {
            try {
                // Traemos todas las ubicaciones (activas e inactivas por ahora)
                const respuesta = await getUbicaciones();
                
                if (respuesta.error) {
                    setError(respuesta.error);
                } else {
                    const dataObtenida = (respuesta as any).ubicaciones || respuesta.data || [];
                    setUbicaciones(dataObtenida);
                }
            } catch (err) {
                setError(err instanceof Error ? err.message : "Error desconocido");
            } finally {
                setCargando(false);
            }
        };

        fetchUbicaciones();
    }, []);

    if (error) return (
        <div className="p-6 text-center text-red-500 font-bold">
            Error: {error}
        </div>
    );

    return (
        <div className="p-6 space-y-6">
            <h1 className="text-3xl font-bold text-gray-800">Catálogo de Ubicaciones</h1>
            
            <TableContainer component={Paper} className="shadow-sm border border-gray-100">
                <Table stickyHeader size="small">
                    <TableHead>
                        <TableRow>
                            <TableCell><strong>ID</strong></TableCell>
                            <TableCell><strong>Nombre</strong></TableCell>
                            <TableCell><strong>Pertenece a (Padre)</strong></TableCell>
                            <TableCell><strong>Descripción</strong></TableCell>
                            <TableCell><strong>Estado</strong></TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {cargando ? (
                            <TableRow>
                                <TableCell colSpan={5} align="center" className="py-8">
                                    Cargando ubicaciones...
                                </TableCell>
                            </TableRow>
                        ) : ubicaciones.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={5} align="center" className="py-8 text-gray-500">
                                    No hay ubicaciones registradas
                                </TableCell>
                            </TableRow>
                        ) : (
                            ubicaciones.map((ubicacion) => (
                                <TableRow 
                                    key={ubicacion.idUbicacion}
                                    hover
                                    // A futuro aquí agregaremos el onClick para ver detalles/activos
                                    style={{ cursor: 'pointer' }}
                                >
                                    <TableCell>{ubicacion.idUbicacion}</TableCell>
                                    <TableCell className="font-medium text-gray-900">
                                        {ubicacion.nombre}
                                    </TableCell>
                                    <TableCell className="text-gray-600">
                                        {ubicacion.nombreUbicacionPadre ? (
                                            <span className="flex items-center gap-1">
                                                <span className="text-gray-400">↳</span> {ubicacion.nombreUbicacionPadre}
                                            </span>
                                        ) : (
                                            <span className="text-gray-400 italic">Ubicación Raíz</span>
                                        )}
                                    </TableCell>
                                    <TableCell className="text-gray-500 max-w-xs truncate">
                                        {ubicacion.descripcion || "-"}
                                    </TableCell>
                                    <TableCell>
                                        <Chip 
                                            label={ubicacion.estado === 'A' ? 'Activa' : 'Inactiva'} 
                                            color={ubicacion.estado === 'A' ? 'success' : 'default'}
                                            size="small"
                                            variant={ubicacion.estado === 'A' ? 'filled' : 'outlined'}
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