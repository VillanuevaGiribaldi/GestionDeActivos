import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
    listarPersonas,
    crearPersona,
    modificarPersona,
    bajaPersona,
    altaPersona,
} from '../../assets/services/personaService';
import type { Persona } from '../../types/persona';
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

export default function Personas() {
    const [personas, setPersonas] = useState<Persona[]>([]);
    const [cargando, setCargando] = useState(true);
    const [error, setError] = useState<string | null>(null);

    // Estados del modal de creación / edición
    const [modalAbierto, setModalAbierto] = useState(false);
    const [personaEditando, setPersonaEditando] = useState<Persona | null>(null);
    const [nombre, setNombre] = useState('');
    const [apellido, setApellido] = useState('');
    const [dni, setDni] = useState('');
    const [cargo, setCargo] = useState('');
    const [guardando, setGuardando] = useState(false);
    const [errorForm, setErrorForm] = useState<string | null>(null);

    // Estados del modal de confirmación para baja / alta
    const [personaCambioEstado, setPersonaCambioEstado] = useState<Persona | null>(null);
    const [procesandoEstado, setProcesandoEstado] = useState(false);
    const [errorEstado, setErrorEstado] = useState<string | null>(null);

    const navigate = useNavigate();

    const handleFilaClick = (idPersona: number) => {
        navigate(`/activos?idPersona=${idPersona}`);
    };

    const fetchPersonas = async () => {
        setCargando(true);
        try {
            const respuesta = await listarPersonas();
            if (respuesta.error) {
                setError(respuesta.error);
            } else {
                const dataObtenida = (respuesta as any).personas || respuesta.data || [];
                setPersonas(dataObtenida);
            }
        } catch (err) {
            setError(err instanceof Error ? err.message : "Error desconocido");
        } finally {
            setCargando(false);
        }
    };

    useEffect(() => {
        fetchPersonas();
    }, []);

    // --- Crear / Editar ---
    const handleAbrirCrear = () => {
        setPersonaEditando(null);
        setNombre('');
        setApellido('');
        setDni('');
        setCargo('');
        setErrorForm(null);
        setModalAbierto(true);
    };

    const handleAbrirEditar = (e: React.MouseEvent, persona: Persona) => {
        e.stopPropagation();
        setPersonaEditando(persona);
        setNombre(persona.nombre);
        setApellido(persona.apellido);
        setDni(persona.dni || '');
        setCargo(persona.cargo || '');
        setErrorForm(null);
        setModalAbierto(true);
    };

    const handleCerrarModal = () => {
        if (guardando) return;
        setModalAbierto(false);
        setPersonaEditando(null);
        setNombre('');
        setApellido('');
        setDni('');
        setCargo('');
        setErrorForm(null);
    };

    const handleGuardarPersona = async (e: React.FormEvent) => {
        e.preventDefault();
        setErrorForm(null);

        if (!nombre.trim() || !apellido.trim() || !dni.trim() ||  !cargo.trim()) {
            setErrorForm("Nombre, apellido y cargo son obligatorios");
            return;
        }

        setGuardando(true);
        try {
            const payload = {
                nombre: nombre.trim(),
                apellido: apellido.trim(),
                dni: dni.trim() || null,
                cargo: cargo.trim(),
            };

            const respuesta = personaEditando
                ? await modificarPersona(personaEditando.idPersona, payload)
                : await crearPersona(payload);

            if (respuesta.error) {
                setErrorForm(respuesta.error);
            } else {
                handleCerrarModal();
                await fetchPersonas();
            }
        } catch (err) {
            setErrorForm(
                err instanceof Error
                    ? err.message
                    : personaEditando
                        ? "No se pudo modificar la persona"
                        : "No se pudo crear la persona"
            );
        } finally {
            setGuardando(false);
        }
    };

    // --- Baja / Alta lógica ---
    const handleAbrirCambioEstado = (e: React.MouseEvent, persona: Persona) => {
        e.stopPropagation();
        setErrorEstado(null);
        setPersonaCambioEstado(persona);
    };

    const handleCerrarCambioEstado = () => {
        if (procesandoEstado) return;
        setPersonaCambioEstado(null);
        setErrorEstado(null);
    };

    const handleConfirmarCambioEstado = async () => {
        if (!personaCambioEstado) return;

        setProcesandoEstado(true);
        setErrorEstado(null);

        const esActiva = personaCambioEstado.estado === 'A';
        try {
            const respuesta = esActiva
                ? await bajaPersona(personaCambioEstado.idPersona)
                : await altaPersona(personaCambioEstado.idPersona);

            if (respuesta.error) {
                setErrorEstado(respuesta.error);
            } else {
                handleCerrarCambioEstado();
                await fetchPersonas();
            }
        } catch (err) {
            setErrorEstado(
                err instanceof Error
                    ? err.message
                    : esActiva
                        ? "No se pudo dar de baja la persona"
                        : "No se pudo reactivar la persona"
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

    const estaActivaSeleccionada = personaCambioEstado?.estado === 'A';

    return (
        <div className="p-6 space-y-6">
            <div className="flex items-center justify-between">
                <h1 className="text-3xl font-bold text-gray-800">Catálogo de Personas</h1>
                <Button
                    variant="contained"
                    startIcon={<AddIcon />}
                    onClick={handleAbrirCrear}
                >
                    Nueva Persona
                </Button>
            </div>

            <TableContainer component={Paper} className="shadow-sm border border-gray-100">
                <Table stickyHeader size="small">
                    <TableHead>
                        <TableRow>
                            <TableCell><strong>ID</strong></TableCell>
                            <TableCell><strong>Nombre Completo</strong></TableCell>
                            <TableCell><strong>DNI</strong></TableCell>
                            <TableCell><strong>Cargo</strong></TableCell>
                            <TableCell><strong>Estado</strong></TableCell>
                            <TableCell align="right"><strong>Acciones</strong></TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {cargando ? (
                            <TableRow>
                                <TableCell colSpan={6} align="center" className="py-8">
                                    Cargando personal...
                                </TableCell>
                            </TableRow>
                        ) : personas.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={6} align="center" className="py-8 text-gray-500">
                                    No hay personas registradas
                                </TableCell>
                            </TableRow>
                        ) : (
                            personas.map((persona) => {
                                const esActiva = persona.estado === 'A';
                                return (
                                    <TableRow
                                        key={persona.idPersona}
                                        hover
                                        onClick={() => handleFilaClick(persona.idPersona)}
                                        style={{ cursor: 'pointer' }}
                                    >
                                        <TableCell>{persona.idPersona}</TableCell>
                                        <TableCell className="font-medium text-gray-900">
                                            {persona.nombre} {persona.apellido}
                                        </TableCell>
                                        <TableCell className="text-gray-600">
                                            {persona.dni || "-"}
                                        </TableCell>
                                        <TableCell className="text-gray-600">
                                            {persona.cargo || "-"}
                                        </TableCell>
                                        <TableCell>
                                            <Chip
                                                label={esActiva ? 'Activo' : 'Inactivo'}
                                                color={esActiva ? 'success' : 'default'}
                                                size="small"
                                                variant={esActiva ? 'filled' : 'outlined'}
                                            />
                                        </TableCell>
                                        <TableCell align="right" className="whitespace-nowrap">
                                            <Tooltip title="Editar persona">
                                                <IconButton
                                                    size="small"
                                                    color="primary"
                                                    onClick={(e) => handleAbrirEditar(e, persona)}
                                                >
                                                    <EditIcon fontSize="small" />
                                                </IconButton>
                                            </Tooltip>

                                            {esActiva ? (
                                                <Tooltip title="Dar de baja">
                                                    <IconButton
                                                        size="small"
                                                        color="error"
                                                        onClick={(e) => handleAbrirCambioEstado(e, persona)}
                                                    >
                                                        <BlockIcon fontSize="small" />
                                                    </IconButton>
                                                </Tooltip>
                                            ) : (
                                                <Tooltip title="Dar de alta">
                                                    <IconButton
                                                        size="small"
                                                        color="success"
                                                        onClick={(e) => handleAbrirCambioEstado(e, persona)}
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
                <form onSubmit={handleGuardarPersona}>
                    <DialogTitle>
                        {personaEditando
                            ? `Editar Persona #${personaEditando.idPersona}`
                            : "Nueva Persona"}
                    </DialogTitle>
                    <DialogContent className="space-y-4 !pt-2">
                        {errorForm && <Alert severity="error">{errorForm}</Alert>}

                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <TextField
                                label="Nombre"
                                fullWidth
                                required
                                autoFocus
                                value={nombre}
                                onChange={(e) => setNombre(e.target.value)}
                                placeholder="Ej: Lucía"
                            />
                            <TextField
                                label="Apellido"
                                fullWidth
                                required
                                value={apellido}
                                onChange={(e) => setApellido(e.target.value)}
                                placeholder="Ej: Morales"
                            />
                        </div>

                        <TextField
                            label="DNI"
                            fullWidth
                            required
                            value={dni}
                            onChange={(e) => setDni(e.target.value)}
                            placeholder="Ej: 36543210 (opcional)"
                        />

                        <TextField
                            label="Cargo"
                            fullWidth
                            required
                            value={cargo}
                            onChange={(e) => setCargo(e.target.value)}
                            placeholder="Ej: Analista de Sistemas"
                        />
                    </DialogContent>
                    <DialogActions className="px-6 pb-4">
                        <Button onClick={handleCerrarModal} disabled={guardando}>
                            Cancelar
                        </Button>
                        <Button type="submit" variant="contained" disabled={guardando}>
                            {guardando
                                ? "Guardando..."
                                : personaEditando
                                    ? "Guardar Cambios"
                                    : "Guardar"}
                        </Button>
                    </DialogActions>
                </form>
            </Dialog>

            {/* Modal de Confirmación de Baja / Alta */}
            <Dialog
                open={Boolean(personaCambioEstado)}
                onClose={handleCerrarCambioEstado}
                fullWidth
                maxWidth="xs"
            >
                <DialogTitle>
                    {estaActivaSeleccionada ? "Dar de baja persona" : "Reactivar persona"}
                </DialogTitle>
                <DialogContent className="space-y-3">
                    {errorEstado && <Alert severity="error">{errorEstado}</Alert>}
                    <DialogContentText>
                        {estaActivaSeleccionada
                            ? `¿Seguro que deseas dar de baja a "${personaCambioEstado?.nombre} ${personaCambioEstado?.apellido}"? Si posee una cuenta de usuario asociada, también será desactivada.`
                            : `¿Deseas volver a dar de alta a "${personaCambioEstado?.nombre} ${personaCambioEstado?.apellido}"?`}
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