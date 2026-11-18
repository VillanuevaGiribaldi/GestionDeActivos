import { useEffect, useState } from 'react';
import { listarUsuarios } from '../assets/services/usuarioService';
import type { Usuario } from '../types/usuario';
import {
    Table, TableBody, TableCell, TableContainer,
    TableHead, TableRow, Paper, Chip
} from "@mui/material";

export default function Usuarios() {
    const [usuarios, setUsuarios] = useState<Usuario[]>([]);
    const [cargando, setCargando] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const fetchUsuarios = async () => {
            try {
                const respuesta = await listarUsuarios();
                
                if (respuesta.error) {
                    setError(respuesta.error);
                } else {
                    const dataObtenida = (respuesta as any).usuarios || respuesta.data || [];
                    setUsuarios(dataObtenida);
                }
            } catch (err) {
                setError(err instanceof Error ? err.message : "Error desconocido");
            } finally {
                setCargando(false);
            }
        };

        fetchUsuarios();
    }, []);

    if (error) return (
        <div className="p-6 text-center text-red-500 font-bold">
            Error: {error}
        </div>
    );

    return (
        <div className="p-6 space-y-6">
            <h1 className="text-3xl font-bold text-gray-800">Catálogo de Usuarios</h1>
            
            <TableContainer component={Paper} className="shadow-sm border border-gray-100">
                <Table stickyHeader size="small">
                    <TableHead>
                        <TableRow>
                            <TableCell><strong>ID</strong></TableCell>
                            <TableCell><strong>Usuario</strong></TableCell>
                            <TableCell><strong>Rol de Acceso</strong></TableCell>
                            <TableCell><strong>Empleado (Persona)</strong></TableCell>
                            <TableCell><strong>Cargo</strong></TableCell>
                            <TableCell><strong>Estado</strong></TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {cargando ? (
                            <TableRow>
                                <TableCell colSpan={6} align="center" className="py-8">
                                    Cargando usuarios...
                                </TableCell>
                            </TableRow>
                        ) : usuarios.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={6} align="center" className="py-8 text-gray-500">
                                    No hay usuarios registrados
                                </TableCell>
                            </TableRow>
                        ) : (
                            usuarios.map((usuario) => (
                                <TableRow 
                                    key={usuario.idUsuario}
                                    hover
                                    style={{ cursor: 'pointer' }}
                                >
                                    <TableCell>{usuario.idUsuario}</TableCell>
                                    <TableCell className="font-medium text-gray-900">
                                        {usuario.username}
                                    </TableCell>
                                    <TableCell>
                                        {/* Color diferente según el rol (ADMIN_IT u otro) */}
                                        <span className={`text-xs font-bold px-2 py-1 rounded border ${
                                            usuario.rol === 'ADMIN_IT' 
                                            ? 'bg-purple-50 text-purple-700 border-purple-200' 
                                            : 'bg-blue-50 text-blue-700 border-blue-200'
                                        }`}>
                                            {usuario.rol}
                                        </span>
                                    </TableCell>
                                    <TableCell className="text-gray-600">
                                        {usuario.nombrePersona} {usuario.apellidoPersona}
                                    </TableCell>
                                    <TableCell className="text-gray-500">
                                        {usuario.cargoPersona || "-"}
                                    </TableCell>
                                    <TableCell>
                                        <Chip 
                                            label={usuario.estado === 'A' ? 'Activo' : 'Inactivo'} 
                                            color={usuario.estado === 'A' ? 'success' : 'default'}
                                            size="small"
                                            variant={usuario.estado === 'A' ? 'filled' : 'outlined'}
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