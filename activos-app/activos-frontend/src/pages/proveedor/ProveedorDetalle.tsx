import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import type { DetalleItemProveedor, Proveedor } from "../../types/proveedor";
import { getDetalleProveedor, getProveedor } from "../../assets/services/proveedorService";
import "../../styles/Activo.css";
import DetalleProveedor from "./ResumenProveedor";

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

export default function ProveedorDetalle() {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();

    const [proveedor, setProveedor] = useState<Proveedor | null>(null);
    const [cargando, setCargando] = useState(true);
    const [error, setError] = useState("");

    const [detalleProveedor, setDetalleProveedor] = useState<DetalleItemProveedor[]>([]);
    const [cargandoDetalleProveedor, setCargandoDetalleProveedor] = useState(true);
    const [errorDetalle, setErrorDetalle] = useState("");


    useEffect(() => {
        const controller = new AbortController();

        async function fetchProveedor() {
            setCargando(true);
            setError("");
            try {
                if (!id) throw new Error("ID de proveedor inexistente");

                const respuesta = await getProveedor(parseInt(id));

                if (respuesta.error) {
                    setError(respuesta.error);
                } else {
                    // Captura 'proveedor' (formato del controlador) o 'data'
                    const data = (respuesta as any).proveedor || respuesta.data;
                    if (!data) {
                        setError("No se encontró el proveedor indicado");
                    } else {
                        setProveedor(data as Proveedor);
                    }
                }
            } catch (err) {
                setError(err instanceof Error ? err.message : "Error desconocido");
            } finally {
                if (!controller.signal.aborted) setCargando(false);
            }
        }
        async function fetchDetalle() {
            setCargandoDetalleProveedor(true);
            setErrorDetalle("");
            try {
                if (!id) throw new Error("ID de proveedor inexistente");

                const respuesta = await getDetalleProveedor(parseInt(id));

                if (respuesta.error) {
                    setError(respuesta.error);
                } else {
                    
                    const data = respuesta.data;
                    
                    setDetalleProveedor(data);
                    
                }
            } catch (err) {
                setErrorDetalle(err instanceof Error ? err.message : "Error desconocido");
            } finally {
                if (!controller.signal.aborted) setCargandoDetalleProveedor(false);
            }
        }


        fetchProveedor();
        fetchDetalle();
        return () => controller.abort();
    }, [id]);

    if (cargando) return <main className="activo-page"><p>Cargando…</p></main>;
    if (error) return <main className="activo-page"><p className="activo-error">{error}</p></main>;
    if (!proveedor) return null;

    const esActivo = proveedor.estado === "A";
    const resumen = ["Factura", "Mantenimiento"].map(tipo => {
        const items = detalleProveedor.filter(item => item.tipo === tipo);

        return {
            tipo,
            cantidad: items.length,
            total: items.reduce((sum, item) => sum + Number(item.monto), 0),
            activosUnicos: new Set(items.map(item => item.idActivo)).size
        };
    });

    const totalGeneral = resumen.reduce((sum, item) => sum + item.total, 0);

    const totalActivosUnicos = new Set(
        detalleProveedor.map(item => item.idActivo)
    ).size;
    return (
        <main className="activo-page">
            <button
                type="button"
                onClick={() => navigate("/proveedores")}
                className="text-sm text-blue-600 hover:underline mb-4 inline-block cursor-pointer"
            >
                ← Volver a Proveedores
            </button>

            <header className="activo-header">
                <div>
                    <p className="activo-sub">Proveedor #{proveedor.idProveedor}</p>
                    <h1>{proveedor.nombre}</h1>
                </div>
                <span className={esActivo ? "badge badge-ok" : "badge badge-danger"}>
                    {esActivo ? "Activo" : "Inactivo"}
                </span>
            </header>

            <Seccion titulo="Información general">
                <dl className="grid-campos">
                    <Campo etiqueta="Razón social">{proveedor.nombre}</Campo>
                    <Campo etiqueta="Dirección">
                        {proveedor.direccion || <span className="vacio">—</span>}
                    </Campo>
                    <Campo etiqueta="Teléfono">
                        {proveedor.telefono || <span className="vacio">—</span>}
                    </Campo>
                    <Campo etiqueta="Email">
                        {proveedor.mail ? (
                            <a href={`mailto:${proveedor.mail}`} className="text-blue-600 hover:underline">
                                {proveedor.mail}
                            </a>
                        ) : (
                            <span className="vacio">—</span>
                        )}
                    </Campo>
                </dl>
            </Seccion>

            <Seccion titulo="Descripción">
                {proveedor.descripcion ? (
                    <p className="text-gray-700">{proveedor.descripcion}</p>
                ) : (
                    <p className="vacio">Sin descripción cargada.</p>
                )}
            </Seccion>

            <Seccion titulo="Resumen de operaciones">
                <div className="grid-campos">
                    {resumen.map(item => (
                        <Campo etiqueta={item.tipo} key={item.tipo}>
                            <div className="space-y-1">
                                <p>
                                    <strong>{item.cantidad}</strong> operaciones
                                </p>
                                <p>
                                    Total: <strong>
                                        {item.total.toLocaleString("es-AR", {
                                            style: "currency",
                                            currency: "ARS"
                                        })}
                                    </strong>
                                </p>
                                <p>
                                    <strong>{item.activosUnicos}</strong> activos únicos
                                </p>
                            </div>
                        </Campo>
                    ))}
                </div>

                <div className="mt-4 pt-3 border-t border-gray-200 grid-campos" >
                    <Campo etiqueta="Gasto total">
                        <strong>
                            {totalGeneral.toLocaleString("es-AR", {
                                style: "currency",
                                currency: "ARS"
                            })}
                        </strong>
                    </Campo>

                    <Campo etiqueta="Total de activos únicos">
                        <strong>{totalActivosUnicos}</strong>
                    </Campo>
                </div>
            </Seccion>

            <section title="Detalle del Proveedor">
                <DetalleProveedor
                    results={detalleProveedor}
                    loading={cargandoDetalleProveedor}
                />

            </section>
        </main>
    );
}