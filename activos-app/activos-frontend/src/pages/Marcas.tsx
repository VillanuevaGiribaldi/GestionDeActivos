import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { listarMarcas, crearMarca } from '../assets/services/marcaService';
import type { Marca } from '../types/marca';
import {
    Table, TableBody, TableCell, TableContainer,
    TableHead, TableRow, Paper, Chip,
    Button, Dialog, DialogTitle, DialogContent,
    DialogActions, TextField, Alert
} from "@mui/material";
import AddIcon from '@mui/icons-material/Add';

export default function Marcas() {
    const [marcas, setMarcas] = useState<Marca[]>([]);
    const [cargando, setCargando] = useState(true);
    const [error, setError] = useState<string | null>(null);

    // Estados del modal de creación
    const [modalAbierto, setModalAbierto] = useState(false);
    const [nombre, setNombre] = useState('');
    const [descripcion, setDescripcion] = useState('');
    const [guardando, setGuardando] = useState(false);
    const [errorForm, setErrorForm] = useState<string | null>(null);

    const navigate = useNavigate();

    const handleFilaClick = (idMarca: number) => {
        navigate(`/activos?idMarca=${idMarca}`);
    };

    const fetchMarcas = async () => {
        setCargando(true);
        try {
            const respuesta = await listarMarcas();
            if (respuesta.error) {
                setError(respuesta.error);
            } else {
                const dataObtenida = (respuesta as any).marcas || respuesta.data || [];
                setMarcas(dataObtenida);
            }
        } catch (err) {
            setError(err instanceof Error ? err.message : "Error desconocido");
        } finally {
            setCargando(false);
        }
    };

    useEffect(() => {
        fetchMarcas();
    }, []);

    const handleCerrarModal = () => {
        if (guardando) return;
        setModalAbierto(false);
        setNombre('');
        setDescripcion('');
        setErrorForm(null);
    };

    const handleCrearMarca = async (e: React.FormEvent) => {
        e.preventDefault();
        setErrorForm(null);

        if (!nombre.trim()) {
            setErrorForm("El nombre de la marca es obligatorio");
            return;
        }

        setGuardando(true);
        try {
            const respuesta = await crearMarca({
                nombre: nombre.trim(),
                descripcion: descripcion.trim(),
            });

            if (respuesta.error) {
                setErrorForm(respuesta.error);
            } else {
                handleCerrarModal();
                await fetchMarcas();
            }
        } catch (err) {
            setErrorForm(err instanceof Error ? err.message : "No se pudo crear la marca");
        } finally {
            setGuardando(false);
        }
    };

    if (error) return (
        <div className="p-6 text-center text-red-500 font-bold">
            Error: {error}
        </div>
    );

    return (
        <div className="p-6 space-y-6">
            <div className="flex items-center justify-between">
                <h1 className="text-3xl font-bold text-gray-800">Catálogo de Marcas</h1>
                <Button
                    variant="contained"
                    startIcon={<AddIcon />}
                    onClick={() => setModalAbierto(true)}
                >
                    Nueva Marca
                </Button>
            </div>

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
                                    onClick={() => handleFilaClick(marca.idMarca)}
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

            <Dialog open={modalAbierto} onClose={handleCerrarModal} fullWidth maxWidth="sm">
                <form onSubmit={handleCrearMarca}>
                    <DialogTitle>Nueva Marca</DialogTitle>
                    <DialogContent className="space-y-4 !pt-2">
                        {errorForm && <Alert severity="error">{errorForm}</Alert>}

                        <TextField
                            label="Nombre"
                            fullWidth
                            required
                            autoFocus
                            value={nombre}
                            onChange={(e) => setNombre(e.target.value)}
                            placeholder="Ej: ASUS"
                        />
                        <TextField
                            label="Descripción"
                            fullWidth
                            multiline
                            rows={2}
                            value={descripcion}
                            onChange={(e) => setDescripcion(e.target.value)}
                            placeholder="Ej: Fabricante de hardware y notebooks"
                        />
                    </DialogContent>
                    <DialogActions className="px-6 pb-4">
                        <Button onClick={handleCerrarModal} disabled={guardando}>
                            Cancelar
                        </Button>
                        <Button type="submit" variant="contained" disabled={guardando}>
                            {guardando ? "Guardando..." : "Guardar"}
                        </Button>
                    </DialogActions>
                </form>
            </Dialog>
        </div>
    );
}