import { useEffect, useState } from "react";
import type { ActivoAvanzado } from "../types/activoAvanzado";
import BarraBusqueda from "./BarraBusquedaTexto";
import SugerenciasBusqueda from "./SugerenciasBusqueda";
import { buscarActivos } from "../assets/services/busquedaService";
import '../style.css'

export default function Header(){
        const MIN_SEARCH = 2
        const [activos, setActivos] = useState<ActivoAvanzado[]>([]);
        const [cargando, setCargando] = useState(true);
        const [textoBusqueda, setTextoBusqueda] = useState('');
        useEffect(() => {
            const fetchActivos = async () => {
                setCargando(true);
                if(textoBusqueda.length<MIN_SEARCH) return
                try {
                    // Pasamos el texto ingresado como parámetro "filtroTexto" al backend
                    const respuesta = await buscarActivos(textoBusqueda);
                    
                    if (respuesta.data) {
                        setActivos(respuesta.data);
                    }
                } catch (error) {
                    console.error("Error al buscar activos:", error);
                } finally {
                    setCargando(false);
                }
            };
    
            // Un simple "debounce" para no saturar la BD en cada pulsación de tecla
            const delaySearch = setTimeout(fetchActivos, 400);
            return () => clearTimeout(delaySearch);
            
        }, [textoBusqueda]);


    return(
        <>
        <header className="cabezera">
            <div className="barraBusqueda">
                <BarraBusqueda
                    texto={textoBusqueda}
                    onChange={setTextoBusqueda}
                />
                <div >
                    <SugerenciasBusqueda
                    results={activos}
                    loading={cargando}
                    />
                </div>
                
            </div>
            
        </header>
        </>
    )
}