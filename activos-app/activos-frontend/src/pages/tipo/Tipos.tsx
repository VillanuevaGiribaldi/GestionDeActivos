import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
    listarTipos,
    crearTipo,
    modificarTipo,
    bajaTipo,
    altaTipo,
} from '../../assets/services/tipoService';
import type { Tipo } from '../../types/tipo';
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
import InventoryIcon from '@mui/icons-material/Inventory';

export default function Tipos() {
    const [tipos, setTipos] = useState<Tipo[]>([]);
    const [cargando, setCargando] = useState(true);
    const [error, setError] = useState<string | null>(null);

    // Estados del modal de creación / edición
    const [modalAbierto, setModalAbierto] = useState(false);
    const [tipoEditando, setTipoEditando] = useState<Tipo | null>(null);
    const [nombre, setNombre] = useState('');
    const [descripcion, setDescripcion] = useState('');
    const [guardando, setGuardando] = useState(false);
    const [errorForm, setErrorForm] = useState<string | null>(null);

    // Estados del modal de confirmación para baja / alta
    const [tipoCambioEstado, setTipoCambioEstado] = useState<Tipo | null>(null);
    const [procesandoEstado, setProcesandoEstado] = useState(false);
    const [errorEstado, setErrorEstado] = useState<string | null>(null);

    const navigate = useNavigate();

    const handleFilaClick = (idTipo: number) => {
        navigate(`/tipo/${idTipo}`);
    };

    const handleVerActivos = (e: React.MouseEvent, idTipo: number) => {
        e.stopPropagation();
        navigate(`/activos?idTipo=${idTipo}`);
    };

    const fetchTipos = async () => {
        setCargando(true);
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

    useEffect(() => {
        fetchTipos();
    }, []);

    // --- Crear / Editar ---
    const handleAbrirCrear = () => {
        setTipoEditando(null);
        setNombre('');
        setDescripcion('');
        setErrorForm(null);
        setModalAbierto(true);
    };

    const handleAbrirEditar = (e: React.MouseEvent, tipo: Tipo) => {
        e.stopPropagation();
        setTipoEditando(tipo);
        setNombre(tipo.nombre);
        setDescripcion(tipo.descripcion || '');
        setErrorForm(null);
        setModalAbierto(true);
    };

    const handleCerrarModal = () => {
        if (guardando) return;
        setModalAbierto(false);
        setTipoEditando(null);
        setNombre('');
        setDescripcion('');
        setErrorForm(null);
    };

    const handleGuardarTipo = async (e: React.FormEvent) => {
        e.preventDefault();
        setErrorForm(null);

        if (!nombre.trim()) {
            setErrorForm("El nombre del tipo es obligatorio");
            return;
        }

        setGuardando(true);
        try {
            const payload = {
                nombre: nombre.trim(),
                descripcion: descripcion.trim(),
            };

            const respuesta = tipoEditando
                ? await modificarTipo(tipoEditando.idTipo, payload)
                : await crearTipo(payload);

            if (respuesta.error) {
                setErrorForm(respuesta.error);
            } else {
                handleCerrarModal();
                await fetchTipos();
            }
        } catch (err) {
            setErrorForm(
                err instanceof Error
                    ? err.message
                    : tipoEditando
                        ? "No se pudo modificar el tipo"
                        : "No se pudo crear el tipo"
            );
        } finally {
            setGuardando(false);
        }
    };

    // --- Baja / Alta lógica ---
    const handleAbrirCambioEstado = (e: React.MouseEvent, tipo: Tipo) => {
        e.stopPropagation();
        setErrorEstado(null);
        setTipoCambioEstado(tipo);
    };

    const handleCerrarCambioEstado = () => {
        if (procesandoEstado) return;
        setTipoCambioEstado(null);
        setErrorEstado(null);
    };

    const handleConfirmarCambioEstado = async () => {
        if (!tipoCambioEstado) return;

        setProcesandoEstado(true);
        setErrorEstado(null);

        const esActivo = tipoCambioEstado.estado === 'A';
        try {
            const respuesta = esActivo
                ? await bajaTipo(tipoCambioEstado.idTipo)
                : await altaTipo(tipoCambioEstado.idTipo);

            if (respuesta.error) {
                setErrorEstado(respuesta.error);
            } else {
                handleCerrarCambioEstado();
                await fetchTipos();
            }
        } catch (err) {
            setErrorEstado(
                err instanceof Error
                    ? err.message
                    : esActivo
                        ? "No se pudo dar de baja el tipo"
                        : "No se pudo reactivar el tipo"
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

    const estaActivoSeleccionado = tipoCambioEstado?.estado === 'A';

    return (
        <div className="p-6 space-y-6">
            <div className="flex items-center justify-between">
                <h1 className="text-3xl font-bold text-gray-800">Catálogo de Tipos</h1>
                <Button
                    variant="contained"
                    startIcon={<AddIcon />}
                    onClick={handleAbrirCrear}
                >
                    Nuevo Tipo
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
                                    Cargando tipos...
                                </TableCell>
                            </TableRow>
                        ) : tipos.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={5} align="center" className="py-8 text-gray-500">
                                    No hay tipos registrados
                                </TableCell>
                            </TableRow>
                        ) : (
                            tipos.map((tipo) => {
                                const esActivo = tipo.estado === 'A';
                                return (
                                    <TableRow
                                        key={tipo.idTipo}
                                        hover
                                        onClick={() => handleFilaClick(tipo.idTipo)}
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
                                                label={esActivo ? 'Activo' : 'Inactivo'}
                                                color={esActivo ? 'success' : 'default'}
                                                size="small"
                                                variant={esActivo ? 'filled' : 'outlined'}
                                            />
                                        </TableCell>
                                        <TableCell align="right" className="whitespace-nowrap">
                                            <Tooltip title="Ver activos de este tipo">
                                                <IconButton
                                                    size="small"
                                                    color="default"
                                                    onClick={(e) => handleVerActivos(e, tipo.idTipo)}
                                                >
                                                    <InventoryIcon fontSize="small" />
                                                </IconButton>
                                            </Tooltip>

                                            <Tooltip title="Editar tipo">
                                                <IconButton
                                                    size="small"
                                                    color="primary"
                                                    onClick={(e) => handleAbrirEditar(e, tipo)}
                                                >
                                                    <EditIcon fontSize="small" />
                                                </IconButton>
                                            </Tooltip>

                                            {esActivo ? (
                                                <Tooltip title="Dar de baja">
                                                    <IconButton
                                                        size="small"
                                                        color="error"
                                                        onClick={(e) => handleAbrirCambioEstado(e, tipo)}
                                                    >
                                                        <BlockIcon fontSize="small" />
                                                    </IconButton>
                                                </Tooltip>
                                            ) : (
                                                <Tooltip title="Dar de alta">
                                                    <IconButton
                                                        size="small"
                                                        color="success"
                                                        onClick={(e) => handleAbrirCambioEstado(e, tipo)}
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
                <form onSubmit={handleGuardarTipo}>
                    <DialogTitle>
                        {tipoEditando ? `Editar Tipo #${tipoEditando.idTipo}` : "Nuevo Tipo"}
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
                            placeholder="Ej: Impresora"
                        />
                        <TextField
                            label="Descripción"
                            fullWidth
                            multiline
                            rows={2}
                            value={descripcion}
                            onChange={(e) => setDescripcion(e.target.value)}
                            placeholder="Ej: Dispositivo de impresión en red"
                        />
                    </DialogContent>
                    <DialogActions className="px-6 pb-4">
                        <Button onClick={handleCerrarModal} disabled={guardando}>
                            Cancelar
                        </Button>
                        <Button type="submit" variant="contained" disabled={guardando}>
                            {guardando
                                ? "Guardando..."
                                : tipoEditando
                                    ? "Guardar Cambios"
                                    : "Guardar"}
                        </Button>
                    </DialogActions>
                </form>
            </Dialog>

            {/* Modal de Confirmación de Baja / Alta */}
            <Dialog
                open={Boolean(tipoCambioEstado)}
                onClose={handleCerrarCambioEstado}
                fullWidth
                maxWidth="xs"
            >
                <DialogTitle>
                    {estaActivoSeleccionado ? "Dar de baja tipo" : "Reactivar tipo"}
                </DialogTitle>
                <DialogContent className="space-y-3">
                    {errorEstado && <Alert severity="error">{errorEstado}</Alert>}
                    <DialogContentText>
                        {estaActivoSeleccionado
                            ? `¿Seguro que deseas dar de baja el tipo "${tipoCambioEstado?.nombre}"? No se podrá asignar a nuevos activos.`
                            : `¿Deseas volver a dar de alta el tipo "${tipoCambioEstado?.nombre}"?`}
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