import { useEffect, useState } from 'react';
import { getEstados } from '../assets/services/estadoService';
import type { Estado } from '../types/estado';
import {
    Table, TableBody, TableCell, TableContainer,
    TableHead, TableRow, Paper
} from "@mui/material";

export default function Estados() {
    const [estados, setEstados] = useState<Estado[]>([]);
    const [cargando, setCargando] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const fetchEstados = async () => {
            try {
                const respuesta = await getEstados();
                
                if (respuesta.error) {
                    setError(respuesta.error);
                } else {
                    const dataObtenida = (respuesta as any).estados || respuesta.data || [];
                    setEstados(dataObtenida);
                }
            } catch (err) {
                setError(err instanceof Error ? err.message : "Error desconocido");
            } finally {
                setCargando(false);
            }
        };

        fetchEstados();
    }, []);

    if (error) return (
        <div className="p-6 text-center text-red-500 font-bold">
            Error: {error}
        </div>
    );

    return (
        <div className="p-6 space-y-6">
            <h1 className="text-3xl font-bold text-gray-800">Catálogo de Estados</h1>
            
            <TableContainer component={Paper} className="shadow-sm border border-gray-100">
                <Table stickyHeader size="small">
                    <TableHead>
                        <TableRow>
                            <TableCell><strong>ID</strong></TableCell>
                            <TableCell><strong>Nombre</strong></TableCell>
                            <TableCell><strong>Descripción</strong></TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {cargando ? (
                            <TableRow>
                                <TableCell colSpan={3} align="center" className="py-8">
                                    Cargando estados...
                                </TableCell>
                            </TableRow>
                        ) : estados.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={3} align="center" className="py-8 text-gray-500">
                                    No hay estados registrados
                                </TableCell>
                            </TableRow>
                        ) : (
                            estados.map((estado) => (
                                <TableRow 
                                    key={estado.idEstado}
                                    hover
                                    style={{ cursor: 'pointer' }}
                                >
                                    <TableCell>{estado.idEstado}</TableCell>
                                    <TableCell className="font-medium text-gray-900">
                                        {estado.nombre}
                                    </TableCell>
                                    <TableCell className="text-gray-600">
                                        {estado.descripcion || "-"}
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