import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { getPersonas } from '../assets/services/personaService';
import type { Persona } from '../types/persona';
import {
    Table, TableBody, TableCell, TableContainer,
    TableHead, TableRow, Paper, Chip
} from "@mui/material";

export default function Personas() {
    const [personas, setPersonas] = useState<Persona[]>([]);
    const [cargando, setCargando] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const navigate = useNavigate();

    useEffect(() => {
        const fetchPersonas = async () => {
            try {
                const respuesta = await getPersonas();
                
                if (respuesta.error) {
                    setError(respuesta.error);
                } else {
                    // Capturamos 'personas' o 'data' de forma dinámica
                    const dataObtenida = (respuesta as any).personas || respuesta.data || [];
                    setPersonas(dataObtenida);
                }
            } catch (err) {
                setError(err instanceof Error ? err.message : "Error desconocido");
            } finally {
                setCargando(false);
            }
        };

        fetchPersonas();
    }, []);

    if (error) return (
        <div className="p-6 text-center text-red-500 font-bold">
            Error: {error}
        </div>
    );

    return (
        <div className="p-6 space-y-6">
            <h1 className="text-3xl font-bold text-gray-800">Catálogo de Personas</h1>
            
            <TableContainer component={Paper} className="shadow-sm border border-gray-100">
                <Table stickyHeader size="small">
                    <TableHead>
                        <TableRow>
                            <TableCell><strong>ID</strong></TableCell>
                            <TableCell><strong>Nombre Completo</strong></TableCell>
                            <TableCell><strong>DNI</strong></TableCell>
                            <TableCell><strong>Cargo</strong></TableCell>
                            <TableCell><strong>Estado</strong></TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {cargando ? (
                            <TableRow>
                                <TableCell colSpan={5} align="center" className="py-8">
                                    Cargando personal...
                                </TableCell>
                            </TableRow>
                        ) : personas.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={5} align="center" className="py-8 text-gray-500">
                                    No hay personas registradas
                                </TableCell>
                            </TableRow>
                        ) : (
                            personas.map((persona) => (
                                <TableRow 
                                    key={persona.idPersona}
                                    hover
                                    style={{ cursor: 'pointer' }}
                                    // Al hacer clic, navega a la vista de detalle dinámico (EAV)
                                    onClick={() => navigate(`/Persona/${persona.idPersona}`)}
                                >
                                    <TableCell>{persona.idPersona}</TableCell>
                                    <TableCell className="font-medium text-gray-900">
                                        {persona.nombre} {persona.apellido}
                                    </TableCell>
                                    <TableCell className="text-gray-600">{persona.dni}</TableCell>
                                    <TableCell className="text-gray-600">{persona.cargo || "-"}</TableCell>
                                    <TableCell>
                                        <Chip 
                                            label={persona.estado === 'A' ? 'Activo' : 'Inactivo'} 
                                            color={persona.estado === 'A' ? 'success' : 'default'}
                                            size="small"
                                            variant={persona.estado === 'A' ? 'filled' : 'outlined'}
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