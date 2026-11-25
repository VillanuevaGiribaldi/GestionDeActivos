import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
    getEstados,
    crearEstado,
    modificarEstado,
    bajaEstado,
    altaEstado,
} from '../assets/services/estadoService';
import type { Estado } from '../types/estado';
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

export default function Estados() {
    const [estados, setEstados] = useState<Estado[]>([]);
    const [cargando, setCargando] = useState(true);
    const [error, setError] = useState<string | null>(null);

    // Estados del modal de creación / edición
    const [modalAbierto, setModalAbierto] = useState(false);
    const [estadoEditando, setEstadoEditando] = useState<Estado | null>(null);
    const [nombre, setNombre] = useState('');
    const [descripcion, setDescripcion] = useState('');
    const [guardando, setGuardando] = useState(false);
    const [errorForm, setErrorForm] = useState<string | null>(null);

    // Estados del modal de confirmación para baja / alta
    const [estadoCambio, setEstadoCambio] = useState<Estado | null>(null);
    const [procesandoEstado, setProcesandoEstado] = useState(false);
    const [errorEstado, setErrorEstado] = useState<string | null>(null);

    const navigate = useNavigate();

    const handleFilaClick = (idEstado: number) => {
        navigate(`/activos?idEstado=${idEstado}`);
    };

    const fetchEstados = async () => {
        setCargando(true);
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

    useEffect(() => {
        fetchEstados();
    }, []);

    // --- Crear / Editar ---
    const handleAbrirCrear = () => {
        setEstadoEditando(null);
        setNombre('');
        setDescripcion('');
        setErrorForm(null);
        setModalAbierto(true);
    };

    const handleAbrirEditar = (e: React.MouseEvent, item: Estado) => {
        e.stopPropagation();
        setEstadoEditando(item);
        setNombre(item.nombre);
        setDescripcion(item.descripcion || '');
        setErrorForm(null);
        setModalAbierto(true);
    };

    const handleCerrarModal = () => {
        if (guardando) return;
        setModalAbierto(false);
        setEstadoEditando(null);
        setNombre('');
        setDescripcion('');
        setErrorForm(null);
    };

    const handleGuardarEstado = async (e: React.FormEvent) => {
        e.preventDefault();
        setErrorForm(null);

        if (!nombre.trim()) {
            setErrorForm("El nombre del estado es obligatorio");
            return;
        }

        setGuardando(true);
        try {
            const payload = {
                nombre: nombre.trim(),
                descripcion: descripcion.trim(),
            };

            const respuesta = estadoEditando
                ? await modificarEstado(estadoEditando.idEstado, payload)
                : await crearEstado(payload);

            if (respuesta.error) {
                setErrorForm(respuesta.error);
            } else {
                handleCerrarModal();
                await fetchEstados();
            }
        } catch (err) {
            setErrorForm(
                err instanceof Error
                    ? err.message
                    : estadoEditando
                        ? "No se pudo modificar el estado"
                        : "No se pudo crear el estado"
            );
        } finally {
            setGuardando(false);
        }
    };

    // --- Baja / Alta lógica ---
    const handleAbrirCambioEstado = (e: React.MouseEvent, item: Estado) => {
        e.stopPropagation();
        setErrorEstado(null);
        setEstadoCambio(item);
    };

    const handleCerrarCambioEstado = () => {
        if (procesandoEstado) return;
        setEstadoCambio(null);
        setErrorEstado(null);
    };

    const handleConfirmarCambioEstado = async () => {
        if (!estadoCambio) return;

        setProcesandoEstado(true);
        setErrorEstado(null);

        const esActivo = estadoCambio.estado === 'A';
        try {
            const respuesta = esActivo
                ? await bajaEstado(estadoCambio.idEstado)
                : await altaEstado(estadoCambio.idEstado);

            if (respuesta.error) {
                setErrorEstado(respuesta.error);
            } else {
                handleCerrarCambioEstado();
                await fetchEstados();
            }
        } catch (err) {
            setErrorEstado(
                err instanceof Error
                    ? err.message
                    : esActivo
                        ? "No se pudo dar de baja el estado"
                        : "No se pudo reactivar el estado"
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

    const estaActivoSeleccionado = estadoCambio?.estado === 'A';

    return (
        <div className="p-6 space-y-6">
            <div className="flex items-center justify-between">
                <h1 className="text-3xl font-bold text-gray-800">Catálogo de Estados</h1>
                <Button
                    variant="contained"
                    startIcon={<AddIcon />}
                    onClick={handleAbrirCrear}
                >
                    Nuevo Estado
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
                                    Cargando estados...
                                </TableCell>
                            </TableRow>
                        ) : estados.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={5} align="center" className="py-8 text-gray-500">
                                    No hay estados registrados
                                </TableCell>
                            </TableRow>
                        ) : (
                            estados.map((item) => {
                                const esActivo = item.estado === 'A';
                                return (
                                    <TableRow
                                        key={item.idEstado}
                                        hover
                                        onClick={() => handleFilaClick(item.idEstado)}
                                        style={{ cursor: 'pointer' }}
                                    >
                                        <TableCell>{item.idEstado}</TableCell>
                                        <TableCell className="font-medium text-gray-900">
                                            {item.nombre}
                                        </TableCell>
                                        <TableCell className="text-gray-600">
                                            {item.descripcion || "-"}
                                        </TableCell>
                                        <TableCell>
                                            <Chip
                                                label={esActivo ? 'Activo' : 'Inactivo'}
                                                color={esActivo ? 'success' : 'default'}
                                                size="small"
                                                variant={esActivo ? 'filled' : 'outlined'}
                                            />
                                        </TableCell>
                                        <TableCell align="right" className="whitespace-nowrap">
                                            <Tooltip title="Editar estado">
                                                <IconButton
                                                    size="small"
                                                    color="primary"
                                                    onClick={(e) => handleAbrirEditar(e, item)}
                                                >
                                                    <EditIcon fontSize="small" />
                                                </IconButton>
                                            </Tooltip>

                                            {esActivo ? (
                                                <Tooltip title="Dar de baja">
                                                    <IconButton
                                                        size="small"
                                                        color="error"
                                                        onClick={(e) => handleAbrirCambioEstado(e, item)}
                                                    >
                                                        <BlockIcon fontSize="small" />
                                                    </IconButton>
                                                </Tooltip>
                                            ) : (
                                                <Tooltip title="Dar de alta">
                                                    <IconButton
                                                        size="small"
                                                        color="success"
                                                        onClick={(e) => handleAbrirCambioEstado(e, item)}
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
                <form onSubmit={handleGuardarEstado}>
                    <DialogTitle>
                        {estadoEditando ? `Editar Estado #${estadoEditando.idEstado}` : "Nuevo Estado"}
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
                            placeholder="Ej: En Préstamo"
                        />
                        <TextField
                            label="Descripción"
                            fullWidth
                            multiline
                            rows={2}
                            value={descripcion}
                            onChange={(e) => setDescripcion(e.target.value)}
                            placeholder="Ej: Equipo asignado temporalmente"
                        />
                    </DialogContent>
                    <DialogActions className="px-6 pb-4">
                        <Button onClick={handleCerrarModal} disabled={guardando}>
                            Cancelar
                        </Button>
                        <Button type="submit" variant="contained" disabled={guardando}>
                            {guardando
                                ? "Guardando..."
                                : estadoEditando
                                    ? "Guardar Cambios"
                                    : "Guardar"}
                        </Button>
                    </DialogActions>
                </form>
            </Dialog>

            {/* Modal de Confirmación de Baja / Alta */}
            <Dialog
                open={Boolean(estadoCambio)}
                onClose={handleCerrarCambioEstado}
                fullWidth
                maxWidth="xs"
            >
                <DialogTitle>
                    {estaActivoSeleccionado ? "Dar de baja estado" : "Reactivar estado"}
                </DialogTitle>
                <DialogContent className="space-y-3">
                    {errorEstado && <Alert severity="error">{errorEstado}</Alert>}
                    <DialogContentText>
                        {estaActivoSeleccionado
                            ? `¿Seguro que deseas dar de baja el estado "${estadoCambio?.nombre}"? No se podrá asignar a nuevos activos.`
                            : `¿Deseas volver a dar de alta el estado "${estadoCambio?.nombre}"?`}
                    </DialogContentText>
                </DialogContent>
                <DialogActions className="px-6 pb-4">
                    <Button onClick={handleCerrarCambioEstado} disabled={procesandoEstado}>
                        Cancelar
                    </Button>
                    <Button
                        onClick={handleConfirmarCambioEstado}
                        variant="contained"
                        color={estaActivoSeleccionado ? "error" : "success"}
                        disabled={procesandoEstado}
                    >
                        {procesandoEstado
                            ? "Procesando..."
                            : estaActivoSeleccionado
                                ? "Dar de baja"
                                : "Dar de alta"}
                    </Button>
                </DialogActions>
            </Dialog>
        </div>
    );
}