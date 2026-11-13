import { useEffect, useState } from 'react';
import { getProveedores } from '../assets/services/proveedorService';
import type { Proveedor } from '../types/proveedor';
import {
    Table, TableBody, TableCell, TableContainer,
    TableHead, TableRow, Paper, Chip
} from "@mui/material";

export default function Proveedores() {
    const [proveedores, setProveedores] = useState<Proveedor[]>([]);
    const [cargando, setCargando] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const fetchProveedores = async () => {
            try {
                const respuesta = await getProveedores();
                
                if (respuesta.error) {
                    setError(respuesta.error);
                } else {
                    // Capturamos 'proveedores' (como lo envía tu backend) o 'data'
                    const dataObtenida = (respuesta as any).proveedores || respuesta.data || [];
                    setProveedores(dataObtenida);
                }
            } catch (err) {
                setError(err instanceof Error ? err.message : "Error desconocido");
            } finally {
                setCargando(false);
            }
        };

        fetchProveedores();
    }, []);

    if (error) return (
        <div className="p-6 text-center text-red-500 font-bold">
            Error: {error}
        </div>
    );

    return (
        <div className="p-6 space-y-6">
            <h1 className="text-3xl font-bold text-gray-800">Catálogo de Proveedores</h1>
            
            <TableContainer component={Paper} className="shadow-sm border border-gray-100">
                <Table stickyHeader size="small">
                    <TableHead>
                        <TableRow>
                            <TableCell><strong>ID</strong></TableCell>
                            <TableCell><strong>Razón Social</strong></TableCell>
                            <TableCell><strong>Dirección</strong></TableCell>
                            <TableCell><strong>Teléfono</strong></TableCell>
                            <TableCell><strong>Email</strong></TableCell>
                            <TableCell><strong>Estado</strong></TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {cargando ? (
                            <TableRow>
                                <TableCell colSpan={6} align="center" className="py-8">
                                    Cargando proveedores...
                                </TableCell>
                            </TableRow>
                        ) : proveedores.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={6} align="center" className="py-8 text-gray-500">
                                    No hay proveedores registrados
                                </TableCell>
                            </TableRow>
                        ) : (
                            proveedores.map((proveedor) => (
                                <TableRow 
                                    key={proveedor.idProveedor}
                                    hover
                                    style={{ cursor: 'pointer' }}
                                >
                                    <TableCell>{proveedor.idProveedor}</TableCell>
                                    <TableCell className="font-medium text-gray-900">
                                        {proveedor.nombre}
                                    </TableCell>
                                    <TableCell className="text-gray-600">
                                        {proveedor.direccion || "-"}
                                    </TableCell>
                                    <TableCell className="text-gray-600">
                                        {proveedor.telefono || "-"}
                                    </TableCell>
                                    <TableCell className="text-gray-600">
                                        <a href={`mailto:${proveedor.mail}`} className="text-blue-600 hover:underline">
                                            {proveedor.mail || "-"}
                                        </a>
                                    </TableCell>
                                    <TableCell>
                                        <Chip 
                                            label={proveedor.estado === 'A' ? 'Activo' : 'Inactivo'} 
                                            color={proveedor.estado === 'A' ? 'success' : 'default'}
                                            size="small"
                                            variant={proveedor.estado === 'A' ? 'filled' : 'outlined'}
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