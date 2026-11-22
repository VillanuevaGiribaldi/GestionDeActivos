import { useEffect, useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import type { Factura } from "../../types/factura";
import { getFactura } from "../../assets/services/facturaService";
import "../../styles/Activo.css";

const formatearFecha = (iso: string) =>
    new Date(iso).toLocaleString("es-AR", {
        dateStyle: "medium",
        timeStyle: "short",
    });

const formatearMonto = (monto: number | string, moneda: string) =>
    `${moneda} ${Number(monto).toLocaleString("es-AR", {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
    })}`;

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

export default function FacturaDetalle() {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();

    const [factura, setFactura] = useState<Factura | null>(null);
    const [cargando, setCargando] = useState(true);
    const [error, setError] = useState("");

    useEffect(() => {
        const controller = new AbortController();

        async function cargar() {
            setCargando(true);
            setError("");
            try {
                if (!id) throw new Error("ID de factura inexistente");

                const respuesta = await getFactura(parseInt(id));

                if (respuesta.error) {
                    setError(respuesta.error);
                } else {
                    const raw = (respuesta as any).factura || respuesta.data;
                    const data = Array.isArray(raw) ? raw[0] : raw;

                    if (!data) {
                        setError("No se encontró la factura indicada");
                    } else {
                        setFactura(data as Factura);
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
    if (!factura) return null;

    const esVigente = factura.estado === "A";

    return (
        <main className="activo-page">
            <button
                type="button"
                onClick={() => navigate("/facturas")}
                className="text-sm text-blue-600 hover:underline mb-4 inline-block cursor-pointer"
            >
                ← Volver a Facturas
            </button>

            <header className="activo-header">
                <div>
                    <p className="activo-sub">Factura #{factura.idFactura}</p>
                    <h1>{factura.numero}</h1>
                </div>
                <span className={esVigente ? "badge badge-ok" : "badge badge-danger"}>
                    {esVigente ? "Vigente" : "Anulada"}
                </span>
            </header>

            <Seccion titulo="Información general">
                <dl className="grid-campos">
                    <Campo etiqueta="Nro. Comprobante">{factura.numero}</Campo>
                    <Campo etiqueta="Fecha de emisión">{formatearFecha(factura.fecha)}</Campo>
                    <Campo etiqueta="Monto total">
                        {formatearMonto(factura.monto, factura.moneda)}
                    </Campo>
                    <Campo etiqueta="Moneda">{factura.moneda}</Campo>
                    <Campo etiqueta="Proveedor">
                        {factura.idProveedor ? (
                            <Link
                                to={`/proveedor/${factura.idProveedor}`}
                                className="text-blue-600 hover:underline"
                            >
                                {factura.nombreProveedor || `Proveedor #${factura.idProveedor}`}
                            </Link>
                        ) : (
                            <span className="vacio">Sin proveedor asignado</span>
                        )}
                    </Campo>
                </dl>
            </Seccion>

            <Seccion titulo="Comprobante adjunto">
                {factura.ruta ? (
                    <p className="text-gray-700 break-all">{factura.ruta}</p>
                ) : (
                    <p className="vacio">Sin archivo adjunto.</p>
                )}
            </Seccion>
        </main>
    );
}