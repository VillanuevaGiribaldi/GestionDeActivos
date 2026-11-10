import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { buscarActivos } from '../assets/services/busquedaService';
import type { ActivoAvanzado } from '../types/activoAvanzado';
import {
    Table, TableBody, TableCell, TableContainer,
    TableHead, TableRow, Paper, TextField, InputAdornment
} from "@mui/material";
// Necesitas instalar iconos si no lo has hecho: npm install @mui/icons-material
import SearchIcon from '@mui/icons-material/Search';

export default function BuscadorActivos() {
    const [activos, setActivos] = useState<ActivoAvanzado[]>([]);
    const [cargando, setCargando] = useState(true);
    const [textoBusqueda, setTextoBusqueda] = useState('');
    const navigate = useNavigate();

    // Efecto para buscar. Se dispara al montar o cuando el usuario tipea
    useEffect(() => {
        const fetchActivos = async () => {
            setCargando(true);
            try {
                // Pasamos el texto ingresado como parámetro "filtroTexto" al backend
                const respuesta = await buscarActivos(
                    textoBusqueda ? { filtroTexto: textoBusqueda } : undefined
                );
                
                if (respuesta.data) {
                    setActivos(respuesta.data);
                }
            } catch (error) {
                console.error("Error al buscar activos:", error);
            } finally {
                setCargando(false);
            }
        };

        // Un simple "debounce" para no saturar la BD en cada pulsación de tecla
        const delaySearch = setTimeout(fetchActivos, 400);
        return () => clearTimeout(delaySearch);
        
    }, [textoBusqueda]);

    return (
        <div className="p-6 bg-gray-50 min-h-screen">
            <div className="max-w-7xl mx-auto space-y-6">
                <h1 className="text-3xl font-bold text-gray-800">Inventario General</h1>

                {/* Barra de Búsqueda Global */}
                <div className="bg-white p-4 rounded-xl shadow-sm border border-gray-100">
                    <TextField
                        fullWidth
                        variant="outlined"
                        placeholder="Buscar por Nombre, Serie, Modelo, Tipo, Marca o JSON..."
                        value={textoBusqueda}
                        onChange={(e) => setTextoBusqueda(e.target.value)}
                        slotProps={{
                            input: {
                                startAdornment: (
                                    <InputAdornment position="start">
                                        <SearchIcon />
                                    </InputAdornment>
                                ),
                            }
                        }}
                    />
                </div>

                {/* Grilla de Resultados */}
                <TableContainer component={Paper} className="shadow-sm border border-gray-100">
                    <Table stickyHeader size="small">
                        <TableHead>
                            <TableRow>
                                <TableCell><strong>ID</strong></TableCell>
                                <TableCell><strong>Activo</strong></TableCell>
                                <TableCell><strong>Tipo</strong></TableCell>
                                <TableCell><strong>Marca</strong></TableCell>
                                <TableCell><strong>Serie</strong></TableCell>
                                <TableCell><strong>Estado</strong></TableCell>
                                <TableCell><strong>Ubicación</strong></TableCell>
                            </TableRow>
                        </TableHead>
                        <TableBody>
                            {cargando ? (
                                <TableRow>
                                    <TableCell colSpan={7} align="center">Buscando...</TableCell>
                                </TableRow>
                            ) : activos.length === 0 ? (
                                <TableRow>
                                    <TableCell colSpan={7} align="center">No se encontraron activos</TableCell>
                                </TableRow>
                            ) : (
                                activos.map((activo) => (
                                    <TableRow 
                                        key={activo.idActivo}
                                        hover
                                        onClick={() => navigate(`/activo/${activo.idActivo}`)}
                                        style={{ cursor: 'pointer' }}
                                    >
                                        <TableCell>{activo.idActivo}</TableCell>
                                        <TableCell>{activo.nombreActivo}</TableCell>
                                        <TableCell>{activo.tipo}</TableCell>
                                        <TableCell>{activo.marca}</TableCell>
                                        <TableCell>{activo.numeroSerie || "-"}</TableCell>
                                        <TableCell>
                                            <span className={`px-2 py-1 rounded text-xs font-bold ${
                                                activo.estado === 'Operativo' ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
                                            }`}>
                                                {activo.estado}
                                            </span>
                                        </TableCell>
                                        <TableCell>{activo.ubicacion}</TableCell>
                                    </TableRow>
                                ))
                            )}
                        </TableBody>
                    </Table>
                </TableContainer>
            </div>
        </div>
    );
}