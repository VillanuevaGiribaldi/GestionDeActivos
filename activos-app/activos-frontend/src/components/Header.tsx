import { useEffect, useState } from "react";
import type { ActivoAvanzado } from "../types/activoAvanzado";
import BarraBusqueda from "./BarraBusquedaTexto";
import SugerenciasBusqueda from "./SugerenciasBusqueda";
import { buscarActivos } from "../assets/services/busquedaService";
import '../style.css'
import type { FiltrosActivosAvanzado } from "../types/filtrosActivosAvanzado";
import BotonBusqueda from "./BotonBusqueda";
import { Collapse } from "@mui/material";

interface HeaderProps {
    abierto: boolean;
}
export default function Header({abierto}: HeaderProps){
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
                    const filtros: FiltrosActivosAvanzado={filtroTexto: textoBusqueda}
                    const respuesta = await buscarActivos(filtros);
                    
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
        {/* <Collapse in={abierto} orientation="horizontal"> */}

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