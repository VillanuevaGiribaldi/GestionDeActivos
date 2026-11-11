import { useEffect, useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import type { Activo, Componente, Valor } from "../types/activo.tsx";
import "../styles/Activo.css";
import { getActivo } from "../assets/services/activoService.tsx";

/* ---------- helpers ---------- */

const formatearFecha = (iso: string) =>
    new Date(iso).toLocaleString("es-AR", {
        dateStyle: "medium",
        timeStyle: "short",
    });

const formatearPrecio = (precio: string | null) =>
    precio === null
        ? "—"
        : "$ " +
          Number(precio).toLocaleString("es-AR", {
              minimumFractionDigits: 2,
              maximumFractionDigits: 2,
          });

const claseEstado = (estado: string) => {
    const e = estado.toLowerCase();
    if (e.includes("operativo")) return "badge badge-ok";
    if (e.includes("reparaci")) return "badge badge-warn";
    if (e.includes("baja")) return "badge badge-danger";
    return "badge badge-neutral";
};

/* ---------- subcomponentes ---------- */

function Campo({ etiqueta, children }: { etiqueta: string; children: React.ReactNode }) {
    return (
        <div className="campo">
            <dt>{etiqueta}</dt>
            <dd>{children}</dd>
        </div>
    );
}

function Ubicacion({ ruta }: { ruta: string }) {
    const partes = ruta?.split(" > ");
    return (
        <span className="breadcrumb">
            {partes.map((parte, i) => (
                <span key={i}>
                    {i > 0 && <span className="breadcrumb-sep"> › </span>}
                    {parte}
                </span>
            ))}
        </span>
    );
}

function ListaValores({ valores }: { valores: Valor[] }) {
    if (valores.length === 0) {
        return <p className="vacio">Este activo no tiene atributos cargados.</p>;
    }
    return (
        <dl className="grid-campos">
            {valores.map((v) => (
                <Campo key={v.idAtributo} etiqueta={v.Atributo}>
                    {v.valor ?? <span className="vacio">—</span>}
                </Campo>
            ))}
        </dl>
    );
}

function ListaComponentes({ componentes }: { componentes: Componente[] }) {
    if (componentes.length === 0) {
        return <p className="vacio">Este activo no tiene componentes.</p>;
    }
    return (
        <ul className="componentes">
            {componentes.map((c) => (
                <li key={c.idActivo}>
                    <Link to={`/activo/${c.idActivo}`} className="componente">
                        <div className="componente-header">
                            <strong>{c.nombre ?? c["nombre del activo"] ?? `Activo #${c.idActivo}`}</strong>
                            <span className="badge badge-neutral">{c.tipo}</span>
                        </div>
                        <dl className="componente-datos">
                            <Campo etiqueta="Marca">{c.marca}</Campo>
                            <Campo etiqueta="Modelo">{c.modelo ?? "—"}</Campo>
                            <Campo etiqueta="N° de serie">{c.numeroSerie ?? "—"}</Campo>
                        </dl>
                    </Link>
                </li>
            ))}
        </ul>
    );
}

function Seccion({
    titulo,
    cantidad,
    children,
}: {
    titulo: string;
    cantidad?: number;
    children: React.ReactNode;
}) {
    return (
        <section className="card">
            <h2>
                {titulo}
                {cantidad !== undefined && <span className="contador">{cantidad}</span>}
            </h2>
            {children}
        </section>
    );
}

/* ---------- página ---------- */

export default function ActivoPage() {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();

    const [activo, setActivo] = useState<Activo | null>(null);
    const [error, setError] = useState("");
    const [cargando, setCargando] = useState(true);

    useEffect(() => {
        const controller = new AbortController();

        async function cargar() {
            setCargando(true);
            setError("");
            try {
                if(!id){
                    throw new Error("id inexistente")
                }
                const response = await getActivo(parseInt(id)) /*= await fetch(`/api/activo/${id}`, {
                    headers: { Authorization: `Bearer ${getToken()}` },
                    signal: controller.signal,
                });

                if (response.status === 401) {
                    removeToken();
                    navigate("/login", { replace: true });
                    return;
                }*/

                const data =  response.data;
                
                setActivo((data as Activo));
            } catch (error) {
                if (error instanceof Error) {
                    console.log(`${error.name}: ${error.message}`);
                    setError(error.name);
                } else {
                    setError("Error desconocido");
                }
            } finally {
                if (!controller.signal.aborted) setCargando(false);
            }
        }

        cargar();
        return () => controller.abort();
    }, [id, navigate]);

    if (cargando) return <main className="activo-page"><p>Cargando…</p></main>;
    if (error) return <main className="activo-page"><p className="activo-error">{error}</p></main>;
    if (!activo) return null;

    return (
        <main className="activo-page">
            <header className="activo-header">
                <div>
                    <p className="activo-sub">
                        {activo.tipo} · {activo.marca}
                    </p>
                    <h1>{activo["nombre del activo"]}</h1>
                </div>
                <span className={claseEstado(activo.estado)}>{activo.estado}</span>
            </header>

            <Seccion titulo="Información general">
                <dl className="grid-campos">
                    <Campo etiqueta="Tipo">{activo.tipo}</Campo>
                    <Campo etiqueta="Marca">{activo.marca}</Campo>
                    <Campo etiqueta="Modelo">{activo.modelo ?? "—"}</Campo>
                    <Campo etiqueta="N° de serie">{activo.numeroSerie ?? "—"}</Campo>
                    <Campo etiqueta="Ubicación">
                        <Ubicacion ruta={activo.ubicacion} />
                    </Campo>
                    <Campo etiqueta="Asignado a">
                        {activo.personaAsignada ?? <span className="vacio">Sin asignar</span>}
                    </Campo>
                    <Campo etiqueta="Precio unitario">{formatearPrecio(activo.precioUnitario)}</Campo>
                    <Campo etiqueta="Fecha de registro">{formatearFecha(activo.fechaRegistro)}</Campo>
                </dl>
            </Seccion>

            <Seccion titulo="Atributos" cantidad={activo.valores.length}>
                <ListaValores valores={activo.valores} />
            </Seccion>

            <Seccion titulo="Componentes" cantidad={activo.componentes.length}>
                <ListaComponentes componentes={activo.componentes} />
            </Seccion>
        </main>
    );
}