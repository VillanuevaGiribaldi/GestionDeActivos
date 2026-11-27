import { useEffect, useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import type { Tipo } from "../../types/tipo";
import type { Atributo } from "../../types/atributo";
import type { ComposicionTipo } from "../../types/composicionTipo";
import { getTipo, listarTipos } from "../../assets/services/tipoService";
import {
    listarAtributos,
    crearAtributo,
    modificarAtributo,
    eliminarAtributo,
} from "../../assets/services/atributoService";
import {
    listarComponentesDe,
    crearComposicion,
    eliminarComposicion,
} from "../../assets/services/composicionService";
import {
    Table, TableBody, TableCell, TableContainer, TableHead, TableRow,
    Paper, Chip, Button, IconButton, Tooltip, Dialog, DialogTitle,
    DialogContent, DialogContentText, DialogActions, TextField,
    Alert, FormControlLabel, Switch, MenuItem
} from "@mui/material";
import AddIcon from "@mui/icons-material/Add";
import EditIcon from "@mui/icons-material/Edit";
import DeleteIcon from "@mui/icons-material/Delete";
import InventoryIcon from "@mui/icons-material/Inventory";
import "../../styles/Activo.css";

function Campo({ etiqueta, children }: { etiqueta: string; children: React.ReactNode }) {
    return (
        <div className="campo">
            <dt>{etiqueta}</dt>
            <dd>{children}</dd>
        </div>
    );
}

export default function TipoDetalle() {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();
    const idTipoNum = id ? parseInt(id) : NaN;

    const [tipo, setTipo] = useState<Tipo | null>(null);
    const [atributos, setAtributos] = useState<Atributo[]>([]);
    const [componentes, setComponentes] = useState<ComposicionTipo[]>([]);
    const [todosLosTipos, setTodosLosTipos] = useState<Tipo[]>([]);
    const [cargando, setCargando] = useState(true);
    const [error, setError] = useState("");

    // --- Estados modal Atributo (Crear / Editar) ---
    const [modalAtrAbierto, setModalAtrAbierto] = useState(false);
    const [atrEditando, setAtrEditando] = useState<Atributo | null>(null);
    const [atrNombre, setAtrNombre] = useState("");
    const [atrPorDefecto, setAtrPorDefecto] = useState("");
    const [atrObligatorio, setAtrObligatorio] = useState(false);
    const [guardandoAtr, setGuardandoAtr] = useState(false);
    const [errorAtr, setErrorAtr] = useState<string | null>(null);

    // --- Estados modal Eliminar Atributo ---
    const [atrEliminando, setAtrEliminando] = useState<Atributo | null>(null);
    const [procesandoElimAtr, setProcesandoElimAtr] = useState(false);
    const [errorElimAtr, setErrorElimAtr] = useState<string | null>(null);

    // --- Estados modal Agregar Composición ---
    const [modalCompAbierto, setModalCompAbierto] = useState(false);
    const [nombreComponenteSel, setNombreComponenteSel] = useState("");
    const [cantidadMax, setCantidadMax] = useState("1");
    const [guardandoComp, setGuardandoComp] = useState(false);
    const [errorComp, setErrorComp] = useState<string | null>(null);

    // --- Estados modal Eliminar Composición ---
    const [compEliminando, setCompEliminando] = useState<ComposicionTipo | null>(null);
    const [procesandoElimComp, setProcesandoElimComp] = useState(false);
    const [errorElimComp, setErrorElimComp] = useState<string | null>(null);

    const cargarAtributos = async (idTipo: number) => {
        const res = await listarAtributos(idTipo);
        if (!res.error) {
            setAtributos((res as any).atributos || res.data || []);
        }
    };

    const cargarComponentes = async (idTipo: number) => {
        const res = await listarComponentesDe(idTipo);
        if (!res.error) {
            setComponentes((res as any).componentes || res.data || []);
        }
    };

    useEffect(() => {
        let cancelado = false;

        async function cargarTodo() {
            setCargando(true);
            setError("");
            try {
                if (Number.isNaN(idTipoNum)) throw new Error("ID de tipo inexistente");

                const [resTipo, resAtr, resComp, resListaTipos] = await Promise.all([
                    getTipo(idTipoNum),
                    listarAtributos(idTipoNum),
                    listarComponentesDe(idTipoNum),
                    listarTipos({ estado: "A" }),
                ]);

                if (cancelado) return;

                if (resTipo.error) {
                    setError(resTipo.error);
                    return;
                }

                const rawTipo = (resTipo as any).tipo || resTipo.data;
                const dataTipo = Array.isArray(rawTipo) ? rawTipo[0] : rawTipo;
                if (!dataTipo) {
                    setError("No se encontró el tipo indicado");
                    return;
                }

                setTipo(dataTipo as Tipo);
                setAtributos((resAtr as any).atributos || resAtr.data || []);
                setComponentes((resComp as any).componentes || resComp.data || []);
                setTodosLosTipos((resListaTipos as any).tipos || resListaTipos.data || []);
            } catch (err) {
                if (!cancelado) {
                    setError(err instanceof Error ? err.message : "Error desconocido");
                }
            } finally {
                if (!cancelado) setCargando(false);
            }
        }

        cargarTodo();
        return () => {
            cancelado = true;
        };
    }, [idTipoNum]);

    // --- Handlers Atributos ---
    const handleAbrirCrearAtr = () => {
        setAtrEditando(null);
        setAtrNombre("");
        setAtrPorDefecto("");
        setAtrObligatorio(false);
        setErrorAtr(null);
        setModalAtrAbierto(true);
    };

    const handleAbrirEditarAtr = (atr: Atributo) => {
        setAtrEditando(atr);
        setAtrNombre(atr.nombre);
        setAtrPorDefecto(atr.porDefecto || "");
        setAtrObligatorio(Boolean(atr.obligatorio));
        setErrorAtr(null);
        setModalAtrAbierto(true);
    };

    const handleCerrarModalAtr = () => {
        if (guardandoAtr) return;
        setModalAtrAbierto(false);
        setAtrEditando(null);
        setErrorAtr(null);
    };

    const handleGuardarAtr = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!tipo) return;
        setErrorAtr(null);

        if (!atrNombre.trim()) {
            setErrorAtr("El nombre del atributo es obligatorio");
            return;
        }

        setGuardandoAtr(true);
        try {
            const payload = {
                idTipo: tipo.idTipo,
                nombre: atrNombre.trim(),
                porDefecto: atrPorDefecto.trim() || null,
                obligatorio: atrObligatorio,
            };

            const res = atrEditando
                ? await modificarAtributo(atrEditando.idAtributo, payload)
                : await crearAtributo(payload);

            if (res.error) {
                setErrorAtr(res.error);
            } else {
                handleCerrarModalAtr();
                await cargarAtributos(tipo.idTipo);
            }
        } catch (err) {
            setErrorAtr(err instanceof Error ? err.message : "No se pudo guardar el atributo");
        } finally {
            setGuardandoAtr(false);
        }
    };

    const handleConfirmarEliminarAtr = async () => {
        if (!atrEliminando || !tipo) return;
        setProcesandoElimAtr(true);
        setErrorElimAtr(null);

        try {
            const res = await eliminarAtributo(atrEliminando.idAtributo);
            if (res.error) {
                setErrorElimAtr(res.error);
            } else {
                setAtrEliminando(null);
                await cargarAtributos(tipo.idTipo);
            }
        } catch (err) {
            setErrorElimAtr(err instanceof Error ? err.message : "No se pudo eliminar el atributo");
        } finally {
            setProcesandoElimAtr(false);
        }
    };

    // --- Handlers Composición ---
    const tiposDisponiblesParaComponer = todosLosTipos.filter(
        (t) =>
            t.idTipo !== tipo?.idTipo &&
            !componentes.some((c) => c.idTipoComponente === t.idTipo)
    );

    const handleAbrirCrearComp = () => {
        setNombreComponenteSel("");
        setCantidadMax("1");
        setErrorComp(null);
        setModalCompAbierto(true);
    };

    const handleCerrarModalComp = () => {
        if (guardandoComp) return;
        setModalCompAbierto(false);
        setErrorComp(null);
    };

    const handleGuardarComp = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!tipo) return;
        setErrorComp(null);

        if (!nombreComponenteSel) {
            setErrorComp("Debe seleccionar un tipo de componente");
            return;
        }

        const maxNum = cantidadMax.trim() === "" ? null : parseInt(cantidadMax);
        if (maxNum !== null && (Number.isNaN(maxNum) || maxNum < 1)) {
            setErrorComp("La cantidad máxima debe ser un número mayor o igual a 1");
            return;
        }

        setGuardandoComp(true);
        try {
            const res = await crearComposicion({
                nombreTipoPadre: tipo.nombre,
                nombreTipoComponente: nombreComponenteSel,
                cantidadComponentesMaxima: maxNum,
            });

            if (res.error) {
                setErrorComp(res.error);
            } else {
                handleCerrarModalComp();
                await cargarComponentes(tipo.idTipo);
            }
        } catch (err) {
            setErrorComp(err instanceof Error ? err.message : "No se pudo agregar la composición");
        } finally {
            setGuardandoComp(false);
        }
    };

    const handleConfirmarEliminarComp = async () => {
        if (!compEliminando || !tipo) return;
        setProcesandoElimComp(true);
        setErrorElimComp(null);

        try {
            const res = await eliminarComposicion(tipo.idTipo, compEliminando.idTipoComponente);
            if (res.error) {
                setErrorElimComp(res.error);
            } else {
                setCompEliminando(null);
                await cargarComponentes(tipo.idTipo);
            }
        } catch (err) {
            setErrorElimComp(
                err instanceof Error ? err.message : "No se pudo eliminar la composición"
            );
        } finally {
            setProcesandoElimComp(false);
        }
    };

    if (cargando) return <main className="activo-page"><p>Cargando…</p></main>;
    if (error) return <main className="activo-page"><p className="activo-error">{error}</p></main>;
    if (!tipo) return null;

    const esActivo = tipo.estado === "A";

    return (
        <main className="activo-page">
            <button
                type="button"
                onClick={() => navigate("/tipos")}
                className="text-sm text-blue-600 hover:underline mb-4 inline-block cursor-pointer"
            >
                ← Volver a Tipos
            </button>

            <header className="activo-header">
                <div>
                    <p className="activo-sub">Tipo #{tipo.idTipo}</p>
                    <h1>{tipo.nombre}</h1>
                </div>
                <div className="flex items-center gap-3">
                    <Button
                        variant="outlined"
                        size="small"
                        startIcon={<InventoryIcon />}
                        onClick={() => navigate(`/activos?idTipo=${tipo.idTipo}`)}
                    >
                        Ver activos
                    </Button>
                    <span className={esActivo ? "badge badge-ok" : "badge badge-danger"}>
                        {esActivo ? "Activo" : "Inactivo"}
                    </span>
                </div>
            </header>

            <section className="card">
                <h2>Información general</h2>
                <dl className="grid-campos">
                    <Campo etiqueta="Nombre">{tipo.nombre}</Campo>
                    <Campo etiqueta="Descripción">
                        {tipo.descripcion || <span className="vacio">Sin descripción</span>}
                    </Campo>
                </dl>
            </section>

            {/* Sección de Atributos */}
            <section className="card">
                <div className="flex items-center justify-between mb-4">
                    <h2 className="!mb-0">
                        Atributos de la plantilla
                        <span className="contador">{atributos.length}</span>
                    </h2>
                    <Button
                        variant="contained"
                        size="small"
                        startIcon={<AddIcon />}
                        onClick={handleAbrirCrearAtr}
                        disabled={!esActivo}
                    >
                        Nuevo Atributo
                    </Button>
                </div>

                {atributos.length === 0 ? (
                    <p className="vacio">Este tipo todavía no tiene atributos definidos.</p>
                ) : (
                    <TableContainer component={Paper} variant="outlined">
                        <Table size="small">
                            <TableHead>
                                <TableRow>
                                    <TableCell><strong>Nombre</strong></TableCell>
                                    <TableCell><strong>Valor por defecto</strong></TableCell>
                                    <TableCell><strong>Obligatorio</strong></TableCell>
                                    <TableCell align="right"><strong>Acciones</strong></TableCell>
                                </TableRow>
                            </TableHead>
                            <TableBody>
                                {atributos.map((atr) => (
                                    <TableRow key={atr.idAtributo} hover>
                                        <TableCell className="font-medium">{atr.nombre}</TableCell>
                                        <TableCell className="text-gray-600">
                                            {atr.porDefecto || "—"}
                                        </TableCell>
                                        <TableCell>
                                            <Chip
                                                label={atr.obligatorio ? "Sí" : "No"}
                                                color={atr.obligatorio ? "warning" : "default"}
                                                size="small"
                                                variant={atr.obligatorio ? "filled" : "outlined"}
                                            />
                                        </TableCell>
                                        <TableCell align="right" className="whitespace-nowrap">
                                            <Tooltip title="Editar atributo">
                                                <IconButton
                                                    size="small"
                                                    color="primary"
                                                    onClick={() => handleAbrirEditarAtr(atr)}
                                                >
                                                    <EditIcon fontSize="small" />
                                                </IconButton>
                                            </Tooltip>
                                            <Tooltip title="Eliminar atributo">
                                                <IconButton
                                                    size="small"
                                                    color="error"
                                                    onClick={() => {
                                                        setErrorElimAtr(null);
                                                        setAtrEliminando(atr);
                                                    }}
                                                >
                                                    <DeleteIcon fontSize="small" />
                                                </IconButton>
                                            </Tooltip>
                                        </TableCell>
                                    </TableRow>
                                ))}
                            </TableBody>
                        </Table>
                    </TableContainer>
                )}
            </section>

            {/* Sección de Composición de Tipos */}
            <section className="card">
                <div className="flex items-center justify-between mb-4">
                    <h2 className="!mb-0">
                        Componentes permitidos
                        <span className="contador">{componentes.length}</span>
                    </h2>
                    <Button
                        variant="contained"
                        size="small"
                        startIcon={<AddIcon />}
                        onClick={handleAbrirCrearComp}
                        disabled={!esActivo || tiposDisponiblesParaComponer.length === 0}
                    >
                        Agregar Componente
                    </Button>
                </div>

                {componentes.length === 0 ? (
                    <p className="vacio">Este tipo no contiene componentes de otros tipos.</p>
                ) : (
                    <TableContainer component={Paper} variant="outlined">
                        <Table size="small">
                            <TableHead>
                                <TableRow>
                                    <TableCell><strong>Tipo Componente</strong></TableCell>
                                    <TableCell><strong>Cantidad Máxima</strong></TableCell>
                                    <TableCell align="right"><strong>Acciones</strong></TableCell>
                                </TableRow>
                            </TableHead>
                            <TableBody>
                                {componentes.map((comp) => (
                                    <TableRow key={comp.idTipoComponente} hover>
                                        <TableCell className="font-medium">
                                            <Link
                                                to={`/tipo/${comp.idTipoComponente}`}
                                                className="text-blue-600 hover:underline"
                                            >
                                                {comp.nombreComponente}
                                            </Link>
                                        </TableCell>
                                        <TableCell className="text-gray-600">
                                            {comp.cantidadComponentesMaxima ?? "Sin límite"}
                                        </TableCell>
                                        <TableCell align="right">
                                            <Tooltip title="Quitar componente">
                                                <IconButton
                                                    size="small"
                                                    color="error"
                                                    onClick={() => {
                                                        setErrorElimComp(null);
                                                        setCompEliminando(comp);
                                                    }}
                                                >
                                                    <DeleteIcon fontSize="small" />
                                                </IconButton>
                                            </Tooltip>
                                        </TableCell>
                                    </TableRow>
                                ))}
                            </TableBody>
                        </Table>
                    </TableContainer>
                )}
            </section>

            {/* Modal Crear / Editar Atributo */}
            <Dialog open={modalAtrAbierto} onClose={handleCerrarModalAtr} fullWidth maxWidth="sm">
                <form onSubmit={handleGuardarAtr}>
                    <DialogTitle>
                        {atrEditando ? `Editar Atributo #${atrEditando.idAtributo}` : "Nuevo Atributo"}
                    </DialogTitle>
                    <DialogContent className="space-y-4 !pt-2">
                        {errorAtr && <Alert severity="error">{errorAtr}</Alert>}

                        <TextField
                            label="Nombre del atributo"
                            fullWidth
                            required
                            autoFocus
                            value={atrNombre}
                            onChange={(e) => setAtrNombre(e.target.value)}
                            placeholder="Ej: Memoria RAM"
                        />
                        <TextField
                            label="Valor por defecto (opcional)"
                            fullWidth
                            value={atrPorDefecto}
                            onChange={(e) => setAtrPorDefecto(e.target.value)}
                            placeholder="Ej: 16GB"
                        />
                        <FormControlLabel
                            control={
                                <Switch
                                    checked={atrObligatorio}
                                    onChange={(e) => setAtrObligatorio(e.target.checked)}
                                />
                            }
                            label="Campo obligatorio al cargar un activo"
                        />
                    </DialogContent>
                    <DialogActions className="px-6 pb-4">
                        <Button onClick={handleCerrarModalAtr} disabled={guardandoAtr}>
                            Cancelar
                        </Button>
                        <Button type="submit" variant="contained" disabled={guardandoAtr}>
                            {guardandoAtr ? "Guardando..." : "Guardar"}
                        </Button>
                    </DialogActions>
                </form>
            </Dialog>

            {/* Modal Confirmar Eliminación de Atributo */}
            <Dialog
                open={Boolean(atrEliminando)}
                onClose={() => !procesandoElimAtr && setAtrEliminando(null)}
                fullWidth
                maxWidth="xs"
            >
                <DialogTitle>Eliminar atributo</DialogTitle>
                <DialogContent className="space-y-3">
                    {errorElimAtr && <Alert severity="error">{errorElimAtr}</Alert>}
                    <DialogContentText>
                        ¿Seguro que deseas eliminar el atributo "{atrEliminando?.nombre}"? Esta acción solo está permitida si no existen activos registrados bajo este tipo.
                    </DialogContentText>
                </DialogContent>
                <DialogActions className="px-6 pb-4">
                    <Button onClick={() => setAtrEliminando(null)} disabled={procesandoElimAtr}>
                        Cancelar
                    </Button>
                    <Button
                        onClick={handleConfirmarEliminarAtr}
                        variant="contained"
                        color="error"
                        disabled={procesandoElimAtr}
                    >
                        {procesandoElimAtr ? "Eliminando..." : "Eliminar"}
                    </Button>
                </DialogActions>
            </Dialog>

            {/* Modal Agregar Composición */}
            <Dialog open={modalCompAbierto} onClose={handleCerrarModalComp} fullWidth maxWidth="sm">
                <form onSubmit={handleGuardarComp}>
                    <DialogTitle>Agregar componente a "{tipo.nombre}"</DialogTitle>
                    <DialogContent className="space-y-4 !pt-2">
                        {errorComp && <Alert severity="error">{errorComp}</Alert>}

                        <TextField
                            select
                            label="Tipo de componente"
                            fullWidth
                            required
                            value={nombreComponenteSel}
                            onChange={(e) => setNombreComponenteSel(e.target.value)}
                        >
                            {tiposDisponiblesParaComponer.map((t) => (
                                <MenuItem key={t.idTipo} value={t.nombre}>
                                    {t.nombre}
                                </MenuItem>
                            ))}
                        </TextField>

                        <TextField
                            label="Cantidad máxima permitida"
                            type="number"
                            fullWidth
                            slotProps={{ htmlInput: { min: 1 } }}
                            value={cantidadMax}
                            onChange={(e) => setCantidadMax(e.target.value)}
                            helperText="Déjalo vacío si no tiene límite de cantidad"
                        />
                    </DialogContent>
                    <DialogActions className="px-6 pb-4">
                        <Button onClick={handleCerrarModalComp} disabled={guardandoComp}>
                            Cancelar
                        </Button>
                        <Button type="submit" variant="contained" disabled={guardandoComp}>
                            {guardandoComp ? "Guardando..." : "Agregar"}
                        </Button>
                    </DialogActions>
                </form>
            </Dialog>

            {/* Modal Confirmar Eliminación de Composición */}
            <Dialog
                open={Boolean(compEliminando)}
                onClose={() => !procesandoElimComp && setCompEliminando(null)}
                fullWidth
                maxWidth="xs"
            >
                <DialogTitle>Quitar componente</DialogTitle>
                <DialogContent className="space-y-3">
                    {errorElimComp && <Alert severity="error">{errorElimComp}</Alert>}
                    <DialogContentText>
                        ¿Seguro que deseas quitar "{compEliminando?.nombreComponente}" como componente permitido de "{tipo.nombre}"?
                    </DialogContentText>
                </DialogContent>
                <DialogActions className="px-6 pb-4">
                    <Button onClick={() => setCompEliminando(null)} disabled={procesandoElimComp}>
                        Cancelar
                    </Button>
                    <Button
                        onClick={handleConfirmarEliminarComp}
                        variant="contained"
                        color="error"
                        disabled={procesandoElimComp}
                    >
                        {procesandoElimComp ? "Quitando..." : "Quitar"}
                    </Button>
                </DialogActions>
            </Dialog>
        </main>
    );
}