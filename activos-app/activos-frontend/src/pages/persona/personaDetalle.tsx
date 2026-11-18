import ResultadosBusqueda from '../../components/ResultadosBusqueda.tsx';
import type { ActivoAvanzado } from '../../types/activoAvanzado.tsx';
import { useEffect,useState } from 'react';
import { buscarActivos } from '../../assets/services/busquedaService.tsx';
import type { FiltrosActivosAvanzado } from '../../types/filtrosActivosAvanzado.tsx';
import { useParams } from 'react-router-dom';
import type { Persona } from '../../types/persona.tsx';
import type { Usuario } from '../../types/usuario.tsx';



export default function PersonaDetalle() {
    const [activos, setActivos] = useState<ActivoAvanzado[]>([]);
    const [cargando, setCargando] = useState(true);
    const { id } = useParams<{ id: string }>();
    const [persona, setPersona] = useState<Persona>();
    const [usuario, setUsuario] = useState<Usuario>()
    useEffect(() => {
            const fetchActivos = async () => {
                setCargando(true);
                try {
                    const filtros: FiltrosActivosAvanzado={}
                    if(id){
                        filtros.idPersona=parseInt(id)
                    }
                    // Pasamos el texto ingresado como parámetro "filtroTexto" al backend
                    
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
        
    }, []);
    return(
        <>
            <h1>Detalle Persona</h1>
            <ResultadosBusqueda 
                results={activos}
                loading={cargando}
                                
            />
        </>
    )
}