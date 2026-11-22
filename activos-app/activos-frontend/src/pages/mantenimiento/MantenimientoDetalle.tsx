import { useEffect, useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import type { Mantenimiento } from "../../types/mantenimiento";
import { getMantenimiento } from "../../assets/services/mantenimientoService";
import "../../styles/Activo.css";

const formatearFecha = (iso: string | null) =>
    iso
        ? new Date(iso).toLocaleDateString("es-AR", {
              dateStyle: "medium",
          })
        : "—";

const formatearCosto = (costo: number | string | null) =>
    costo === null || costo === undefined
        ? "—"
        : "$ " +
          Number(costo).toLocaleString("es-AR", {
              minimumFractionDigits: 2,
              maximumFractionDigits: 2,
          });

function Campo({ etiqueta, children }: { etiqueta: string; children: React.ReactNode }) {
    return (
        <div className="campo">
            <dt>{etiqueta}</dt>
            <dd>{children}</dd>
        </div>
    );
}

function Seccion({ titulo, children }: { titulo: string; children: React.ReactNode }) {
    return (
        <section className="card">
            <h2>{titulo}</h2>
            {children}
        </section>
    );
}

export default function MantenimientoDetalle() {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();

    const [mantenimiento, setMantenimiento] = useState<Mantenimiento | null>(null);
    const [cargando, setCargando] = useState(true);
    const [error, setError] = useState("");

    useEffect(() => {
        const controller = new AbortController();

        async function cargar() {
            setCargando(true);
            setError("");
            try {
                if (!id) throw new Error("ID de mantenimiento inexistente");

                const respuesta = await getMantenimiento(parseInt(id));

                if (respuesta.error) {
                    setError(respuesta.error);
                } else {
                    const raw = (respuesta as any).mantenimiento || respuesta.data;
                    const data = Array.isArray(raw) ? raw[0] : raw;

                    if (!data) {
                        setError("No se encontró el mantenimiento indicado");
                    } else {
                        setMantenimiento(data as Mantenimiento);
                    }
                }
            } catch (err) {
                setError(err instanceof Error ? err.message : "Error desconocido");
            } finally {
                if (!controller.signal.aborted) setCargando(false);
            }
        }

        cargar();
        return () => controller.abort();
    }, [id]);

    if (cargando) return <main className="activo-page"><p>Cargando…</p></main>;
    if (error) return <main className="activo-page"><p className="activo-error">{error}</p></main>;
    if (!mantenimiento) return null;

    const finalizado = Boolean(mantenimiento.fechaDevolucion);

    return (
        <main className="activo-page">
            <button
                type="button"
                onClick={() => navigate("/mantenimientos")}
                className="text-sm text-blue-600 hover:underline mb-4 inline-block cursor-pointer"
            >
                ← Volver a Mantenimientos
            </button>

            <header className="activo-header">
                <div>
                    <p className="activo-sub">Mantenimiento #{mantenimiento.idMantenimiento}</p>
                    <h1>{mantenimiento.nombreActivo || `Activo #${mantenimiento.idActivo}`}</h1>
                </div>
                <span className={finalizado ? "badge badge-ok" : "badge badge-warn"}>
                    {finalizado ? "Finalizado" : "En curso"}
                </span>
            </header>

            <Seccion titulo="Información general">
                <dl className="grid-campos">
                    <Campo etiqueta="Activo">
                        <Link
                            to={`/activo/${mantenimiento.idActivo}`}
                            className="text-blue-600 hover:underline"
                        >
                            {mantenimiento.nombreActivo || `Activo #${mantenimiento.idActivo}`}
                        </Link>
                        {mantenimiento.numeroSerie && (
                            <span className="block text-xs text-gray-500">
                                S/N: {mantenimiento.numeroSerie}
                            </span>
                        )}
                    </Campo>
                    <Campo etiqueta="Proveedor / Servicio técnico">
                        <Link
                            to={`/proveedor/${mantenimiento.idProveedor}`}
                            className="text-blue-600 hover:underline"
                        >
                            {mantenimiento.nombreProveedor || `Proveedor #${mantenimiento.idProveedor}`}
                        </Link>
                    </Campo>
                    <Campo etiqueta="Fecha de envío">
                        {formatearFecha(mantenimiento.fechaEnvio)}
                    </Campo>
                    <Campo etiqueta="Fecha de devolución">
                        {mantenimiento.fechaDevolucion ? (
                            formatearFecha(mantenimiento.fechaDevolucion)
                        ) : (
                            <span className="vacio">Aún en reparación</span>
                        )}
                    </Campo>
                    <Campo etiqueta="Costo total">
                        {formatearCosto(mantenimiento.costoTotal)}
                    </Campo>
                </dl>
            </Seccion>

            <Seccion titulo="Falla reportada">
                {mantenimiento.fallaReportada ? (
                    <p className="text-gray-700">{mantenimiento.fallaReportada}</p>
                ) : (
                    <p className="vacio">Sin detalle de falla.</p>
                )}
            </Seccion>

            <Seccion titulo="Reparación realizada">
                {mantenimiento.reparacionRealizada ? (
                    <p className="text-gray-700">{mantenimiento.reparacionRealizada}</p>
                ) : (
                    <p className="vacio">
                        {finalizado ? "Sin detalle registrado." : "Pendiente de finalización."}
                    </p>
                )}
            </Seccion>
        </main>
    );
}