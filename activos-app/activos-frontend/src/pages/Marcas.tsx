import { useEffect, useState } from 'react';
import { listarMarcas } from '../assets/services/marcaService';
import type { Marca } from '../types/marca';
import {
    Table, TableBody, TableCell, TableContainer,
    TableHead, TableRow, Paper, Chip
} from "@mui/material";
import { useNavigate } from "react-router-dom";

export default function Marcas() {
    const [marcas, setMarcas] = useState<Marca[]>([]);
    const [cargando, setCargando] = useState(true);
    const [error, setError] = useState<string | null>(null);

    // 1. Inicializamos navigate
    const navigate = useNavigate();

    // 2. Creamos la función manejadora
    const handleFilaClick = (idMarca: number) => {
        // Redirige a la pantalla de activos con el filtro aplicado
        navigate(`/activos?idMarca=${idMarca}`);
    };

    useEffect(() => {
        const fetchMarcas = async () => {
            try {
                // Llamamos a nuestro servicio renombrado a listarMarcas
                const respuesta = await listarMarcas();
                
                if (respuesta.error) {
                    setError(respuesta.error);
                } else {
                    // Capturamos el listado dinámicamente
                    const dataObtenida = (respuesta as any).marcas || respuesta.data || [];
                    setMarcas(dataObtenida);
                }
            } catch (err) {
                setError(err instanceof Error ? err.message : "Error desconocido");
            } finally {
                setCargando(false);
            }
        };

        fetchMarcas();
    }, []);

    if (error) return (
        <div className="p-6 text-center text-red-500 font-bold">
            Error: {error}
        </div>
    );

    return (
        <div className="p-6 space-y-6">
            <h1 className="text-3xl font-bold text-gray-800">Catálogo de Marcas</h1>
            
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
                                    Cargando marcas...
                                </TableCell>
                            </TableRow>
                        ) : marcas.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={4} align="center" className="py-8 text-gray-500">
                                    No hay marcas registradas
                                </TableCell>
                            </TableRow>
                        ) : (
                            marcas.map((marca) => (
                                <TableRow 
                                    key={marca.idMarca}
                                    hover
                                    // 3. Agregamos el evento onClick
                                    onClick={() => handleFilaClick(marca.idMarca)}
                                    // Mantenemos el cursor pointer para indicar que es clickeable
                                    style={{ cursor: 'pointer' }}
                                >
                                    <TableCell>{marca.idMarca}</TableCell>
                                    <TableCell className="font-medium text-gray-900">
                                        {marca.nombre}
                                    </TableCell>
                                    <TableCell className="text-gray-600">
                                        {marca.descripcion || "-"}
                                    </TableCell>
                                    <TableCell>
                                        <Chip 
                                            label={marca.estado === 'A' ? 'Activa' : 'Inactiva'} 
                                            color={marca.estado === 'A' ? 'success' : 'default'}
                                            size="small"
                                            variant={marca.estado === 'A' ? 'filled' : 'outlined'}
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