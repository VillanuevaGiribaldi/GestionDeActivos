import { useEffect, useState } from 'react';
import { listarTipos } from '../assets/services/tipoService';
import type { Tipo } from '../types/tipo';
import {
    Table, TableBody, TableCell, TableContainer,
    TableHead, TableRow, Paper, Chip
} from "@mui/material";

export default function Tipos() {
    const [tipos, setTipos] = useState<Tipo[]>([]);
    const [cargando, setCargando] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const fetchTipos = async () => {
            try {
                const respuesta = await listarTipos();
                
                if (respuesta.error) {
                    setError(respuesta.error);
                } else {
                    const dataObtenida = (respuesta as any).tipos || respuesta.data || [];
                    setTipos(dataObtenida);
                }
            } catch (err) {
                setError(err instanceof Error ? err.message : "Error desconocido");
            } finally {
                setCargando(false);
            }
        };

        fetchTipos();
    }, []);

    if (error) return (
        <div className="p-6 text-center text-red-500 font-bold">
            Error: {error}
        </div>
    );

    return (
        <div className="p-6 space-y-6">
            <h1 className="text-3xl font-bold text-gray-800">Catálogo de Tipos</h1>
            
            <TableContainer component={Paper} className="shadow-sm border border-gray-100">
                <Table stickyHeader size="small">
                    <TableHead>
                        <TableRow>
                            <TableCell><strong>ID</strong></TableCell>
                            <TableCell><strong>Nombre</strong></TableCell>
                            <TableCell><strong>Descripción</strong></TableCell>
                            <TableCell><strong>Estado</strong></TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {cargando ? (
                            <TableRow>
                                <TableCell colSpan={4} align="center" className="py-8">
                                    Cargando tipos...
                                </TableCell>
                            </TableRow>
                        ) : tipos.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={4} align="center" className="py-8 text-gray-500">
                                    No hay tipos registrados
                                </TableCell>
                            </TableRow>
                        ) : (
                            tipos.map((tipo) => (
                                <TableRow 
                                    key={tipo.idTipo}
                                    hover
                                    style={{ cursor: 'pointer' }}
                                >
                                    <TableCell>{tipo.idTipo}</TableCell>
                                    <TableCell className="font-medium text-gray-900">
                                        {tipo.nombre}
                                    </TableCell>
                                    <TableCell className="text-gray-600">
                                        {tipo.descripcion || "-"}
                                    </TableCell>
                                    <TableCell>
                                        <Chip 
                                            label={tipo.estado === 'A' ? 'Activo' : 'Inactivo'} 
                                            color={tipo.estado === 'A' ? 'success' : 'default'}
                                            size="small"
                                            variant={tipo.estado === 'A' ? 'filled' : 'outlined'}
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