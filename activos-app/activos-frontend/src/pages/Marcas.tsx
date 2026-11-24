import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
    listarMarcas,
    crearMarca,
    modificarMarca,
    bajaMarca,
    altaMarca,
} from '../assets/services/marcaService';
import type { Marca } from '../types/marca';
import {
    Table, TableBody, TableCell, TableContainer,
    TableHead, TableRow, Paper, Chip,
    Button, IconButton, Tooltip, Dialog, DialogTitle,
    DialogContent, DialogContentText, DialogActions,
    TextField, Alert
} from "@mui/material";
import AddIcon from '@mui/icons-material/Add';
import EditIcon from '@mui/icons-material/Edit';
import BlockIcon from '@mui/icons-material/Block';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';

export default function Marcas() {
    const [marcas, setMarcas] = useState<Marca[]>([]);
    const [cargando, setCargando] = useState(true);
    const [error, setError] = useState<string | null>(null);

    // Estados del modal de creación / edición
    const [modalAbierto, setModalAbierto] = useState(false);
    const [marcaEditando, setMarcaEditando] = useState<Marca | null>(null);
    const [nombre, setNombre] = useState('');
    const [descripcion, setDescripcion] = useState('');
    const [guardando, setGuardando] = useState(false);
    const [errorForm, setErrorForm] = useState<string | null>(null);

    // Estados del modal de confirmación para baja / alta
    const [marcaCambioEstado, setMarcaCambioEstado] = useState<Marca | null>(null);
    const [procesandoEstado, setProcesandoEstado] = useState(false);
    const [errorEstado, setErrorEstado] = useState<string | null>(null);

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

    // --- Crear / Editar ---
    const handleAbrirCrear = () => {
        setMarcaEditando(null);
        setNombre('');
        setDescripcion('');
        setErrorForm(null);
        setModalAbierto(true);
    };

    const handleAbrirEditar = (e: React.MouseEvent, marca: Marca) => {
        e.stopPropagation();
        setMarcaEditando(marca);
        setNombre(marca.nombre);
        setDescripcion(marca.descripcion || '');
        setErrorForm(null);
        setModalAbierto(true);
    };

    const handleCerrarModal = () => {
        if (guardando) return;
        setModalAbierto(false);
        setMarcaEditando(null);
        setNombre('');
        setDescripcion('');
        setErrorForm(null);
    };

    const handleGuardarMarca = async (e: React.FormEvent) => {
        e.preventDefault();
        setErrorForm(null);

        if (!nombre.trim()) {
            setErrorForm("El nombre de la marca es obligatorio");
            return;
        }

        setGuardando(true);
        try {
            const payload = {
                nombre: nombre.trim(),
                descripcion: descripcion.trim(),
            };

            const respuesta = marcaEditando
                ? await modificarMarca(marcaEditando.idMarca, payload)
                : await crearMarca(payload);

            if (respuesta.error) {
                setErrorForm(respuesta.error);
            } else {
                handleCerrarModal();
                await fetchMarcas();
            }
        } catch (err) {
            setErrorForm(
                err instanceof Error
                    ? err.message
                    : marcaEditando
                        ? "No se pudo modificar la marca"
                        : "No se pudo crear la marca"
            );
        } finally {
            setGuardando(false);
        }
    };

    // --- Baja / Alta lógica ---
    const handleAbrirCambioEstado = (e: React.MouseEvent, marca: Marca) => {
        e.stopPropagation();
        setErrorEstado(null);
        setMarcaCambioEstado(marca);
    };

    const handleCerrarCambioEstado = () => {
        if (procesandoEstado) return;
        setMarcaCambioEstado(null);
        setErrorEstado(null);
    };

    const handleConfirmarCambioEstado = async () => {
        if (!marcaCambioEstado) return;

        setProcesandoEstado(true);
        setErrorEstado(null);

        const esActiva = marcaCambioEstado.estado === 'A';
        try {
            const respuesta = esActiva
                ? await bajaMarca(marcaCambioEstado.idMarca)
                : await altaMarca(marcaCambioEstado.idMarca);

            if (respuesta.error) {
                setErrorEstado(respuesta.error);
            } else {
                handleCerrarCambioEstado();
                await fetchMarcas();
            }
        } catch (err) {
            setErrorEstado(
                err instanceof Error
                    ? err.message
                    : esActiva
                        ? "No se pudo dar de baja la marca"
                        : "No se pudo reactivar la marca"
            );
        } finally {
            setProcesandoEstado(false);
        }
    };

    if (error) return (
        <div className="p-6 text-center text-red-500 font-bold">
            Error: {error}
        </div>
    );

    const estaActivaSeleccionada = marcaCambioEstado?.estado === 'A';

    return (
        <div className="p-6 space-y-6">
            <div className="flex items-center justify-between">
                <h1 className="text-3xl font-bold text-gray-800">Catálogo de Marcas</h1>
                <Button
                    variant="contained"
                    startIcon={<AddIcon />}
                    onClick={handleAbrirCrear}
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
                            <TableCell align="right"><strong>Acciones</strong></TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {cargando ? (
                            <TableRow>
                                <TableCell colSpan={5} align="center" className="py-8">
                                    Cargando marcas...
                                </TableCell>
                            </TableRow>
                        ) : marcas.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={5} align="center" className="py-8 text-gray-500">
                                    No hay marcas registradas
                                </TableCell>
                            </TableRow>
                        ) : (
                            marcas.map((marca) => {
                                const esActiva = marca.estado === 'A';
                                return (
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
                                                label={esActiva ? 'Activa' : 'Inactiva'}
                                                color={esActiva ? 'success' : 'default'}
                                                size="small"
                                                variant={esActiva ? 'filled' : 'outlined'}
                                            />
                                        </TableCell>
                                        <TableCell align="right" className="whitespace-nowrap">
                                            <Tooltip title="Editar marca">
                                                <IconButton
                                                    size="small"
                                                    color="primary"
                                                    onClick={(e) => handleAbrirEditar(e, marca)}
                                                >
                                                    <EditIcon fontSize="small" />
                                                </IconButton>
                                            </Tooltip>

                                            {esActiva ? (
                                                <Tooltip title="Dar de baja">
                                                    <IconButton
                                                        size="small"
                                                        color="error"
                                                        onClick={(e) => handleAbrirCambioEstado(e, marca)}
                                                    >
                                                        <BlockIcon fontSize="small" />
                                                    </IconButton>
                                                </Tooltip>
                                            ) : (
                                                <Tooltip title="Dar de alta">
                                                    <IconButton
                                                        size="small"
                                                        color="success"
                                                        onClick={(e) => handleAbrirCambioEstado(e, marca)}
                                                    >
                                                        <CheckCircleIcon fontSize="small" />
                                                    </IconButton>
                                                </Tooltip>
                                            )}
                                        </TableCell>
                                    </TableRow>
                                );
                            })
                        )}
                    </TableBody>
                </Table>
            </TableContainer>

            {/* Modal de Crear / Editar */}
            <Dialog open={modalAbierto} onClose={handleCerrarModal} fullWidth maxWidth="sm">
                <form onSubmit={handleGuardarMarca}>
                    <DialogTitle>
                        {marcaEditando ? `Editar Marca #${marcaEditando.idMarca}` : "Nueva Marca"}
                    </DialogTitle>
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
                            {guardando
                                ? "Guardando..."
                                : marcaEditando
                                    ? "Guardar Cambios"
                                    : "Guardar"}
                        </Button>
                    </DialogActions>
                </form>
            </Dialog>

            {/* Modal de Confirmación de Baja / Alta */}
            <Dialog
                open={Boolean(marcaCambioEstado)}
                onClose={handleCerrarCambioEstado}
                fullWidth
                maxWidth="xs"
            >
                <DialogTitle>
                    {estaActivaSeleccionada ? "Dar de baja marca" : "Reactivar marca"}
                </DialogTitle>
                <DialogContent className="space-y-3">
                    {errorEstado && <Alert severity="error">{errorEstado}</Alert>}
                    <DialogContentText>
                        {estaActivaSeleccionada
                            ? `¿Seguro que deseas dar de baja la marca "${marcaCambioEstado?.nombre}"? Dejará de estar disponible para nuevos activos.`
                            : `¿Deseas volver a dar de alta la marca "${marcaCambioEstado?.nombre}"?`}
                    </DialogContentText>
                </DialogContent>
                <DialogActions className="px-6 pb-4">
                    <Button onClick={handleCerrarCambioEstado} disabled={procesandoEstado}>
                        Cancelar
                    </Button>
                    <Button
                        onClick={handleConfirmarCambioEstado}
                        variant="contained"
                        color={estaActivaSeleccionada ? "error" : "success"}
                        disabled={procesandoEstado}
                    >
                        {procesandoEstado
                            ? "Procesando..."
                            : estaActivaSeleccionada
                                ? "Dar de baja"
                                : "Dar de alta"}
                    </Button>
                </DialogActions>
            </Dialog>
        </div>
    );
}