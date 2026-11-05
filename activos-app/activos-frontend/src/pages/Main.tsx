import { use, useEffect, useState } from 'react';
import type {ActivosResumen} from '../types/activosResumen.tsx'
import Resumen from '../components/Resumen.tsx';
import { getToken } from "../auth/auth";


function Main() {
    const [dataResumen, setDataResumen]=useState<ActivosResumen[]>([])
    const [cargandoResumen, setCargandoResumen]= useState(true)
    const [errorResumen, setErrorResumen] = useState<string | null>(null)

    useEffect(()=>{
        const controller = new AbortController();
        const fetchResumen = async () => {
            try {
                const fetchResumen = await fetch('/api/activo/resumen', {
                        headers: { Authorization: `Bearer ${getToken()}` },
                        signal: controller.signal,
                    });
                if (!fetchResumen.ok){
                    const mensajeError=await fetchResumen.json()
                    throw new Error("Error al cargar el resumen:"+mensajeError.message);
                }
                const datosResumen = await fetchResumen.json()
                setDataResumen(datosResumen.activos)
            } catch (error) {
                setErrorResumen(error instanceof Error ? error.message : "Error desconocido")
            } finally{
                setCargandoResumen(false)
            }
        }
        fetchResumen()
    },[])
    const columnLabels: Record<string, string> = {
    idActivo: "ID",
    nombre: "Nombre",
    marca: "Marca",
    modelo: "Modelo",
    tipoActivo: "Tipo de activo",
    precio: "Precio"
    };
    
    if (cargandoResumen) return <p>cargando resumen de activos...</p>;
    if (errorResumen) return <p>Error: {errorResumen}</p>;
    return(
        <>
        <h1>Hola Main</h1>
        <Resumen data={dataResumen} labels={columnLabels} />
        </>
    )
    
}
export default Main;