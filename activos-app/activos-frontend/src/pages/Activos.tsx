import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { buscarActivos } from '../assets/services/busquedaService';
import type { ActivoAvanzado } from '../types/activoAvanzado';
import {
    Table, TableBody, TableCell, TableContainer,
    TableHead, TableRow, Paper, Chip
} from "@mui/material";

export default function Activos() {
    const [activos, setActivos] = useState<ActivoAvanzado[]>([]);
    const [cargando, setCargando] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const navigate = useNavigate();

    useEffect(() => {
        const fetchActivos = async () => {
            try {
                // Al no enviar parámetros, el SP listará todo el catálogo por defecto
                const respuesta = await buscarActivos();
                
                if (respuesta.error) {
                    setError(respuesta.error);
                } else {
                    // Capturamos 'activos' como lo envía el backend en activos.controller.js
                    const dataObtenida = (respuesta as any).activos || respuesta.data || [];
                    setActivos(dataObtenida);
                }
            } catch (err) {
                setError(err instanceof Error ? err.message : "Error desconocido");
            } finally {
                setCargando(false);
            }
        };

        fetchActivos();
    }, []);

    if (error) return (
        <div className="p-6 text-center text-red-500 font-bold">
            Error: {error}
        </div>
    );

    return (
        <div className="p-6 space-y-6">
            <h1 className="text-3xl font-bold text-gray-800">Catálogo de Activos</h1>
            
            <TableContainer component={Paper} className="shadow-sm border border-gray-100">
                <Table stickyHeader size="small">
                    <TableHead>
                        <TableRow>
                            <TableCell><strong>ID</strong></TableCell>
                            <TableCell><strong>Activo</strong></TableCell>
                            <TableCell><strong>Tipo</strong></TableCell>
                            <TableCell><strong>Marca</strong></TableCell>
                            <TableCell><strong>Nro. Serie</strong></TableCell>
                            <TableCell><strong>Ubicación</strong></TableCell>
                            <TableCell><strong>Estado</strong></TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {cargando ? (
                            <TableRow>
                                <TableCell colSpan={7} align="center" className="py-8">
                                    Cargando inventario...
                                </TableCell>
                            </TableRow>
                        ) : activos.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={7} align="center" className="py-8 text-gray-500">
                                    No hay activos registrados en el sistema
                                </TableCell>
                            </TableRow>
                        ) : (
                            activos.map((activo) => (
                                <TableRow 
                                    key={activo.idActivo}
                                    hover
                                    // Al hacer clic, navega a la vista de detalle dinámico (EAV)
                                    onClick={() => navigate(`/activo/${activo.idActivo}`)}
                                    style={{ cursor: 'pointer' }}
                                >
                                    <TableCell>{activo.idActivo}</TableCell>
                                    <TableCell className="font-medium text-gray-900">
                                        {activo.nombreActivo}
                                    </TableCell>
                                    <TableCell className="text-gray-600">{activo.tipo}</TableCell>
                                    <TableCell className="text-gray-600">{activo.marca}</TableCell>
                                    <TableCell className="text-gray-500">{activo.numeroSerie || "-"}</TableCell>
                                    <TableCell className="text-gray-600">{activo.ubicacion}</TableCell>
                                    <TableCell>
                                        <Chip 
                                            label={activo.estado} 
                                            color={activo.estado === 'Operativo' ? 'success' : activo.estado === 'En Reparación' ? 'warning' : 'default'}
                                            size="small"
                                            variant="filled"
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