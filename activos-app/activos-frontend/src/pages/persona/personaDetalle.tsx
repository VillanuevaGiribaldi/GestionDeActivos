import ResultadosBusqueda from '../../components/ResultadosBusqueda.tsx';
import type { ActivoAvanzado } from '../../types/activoAvanzado.tsx';
import { useEffect,useState } from 'react';
import { buscarActivos } from '../../assets/services/busquedaService.tsx';
import type { FiltrosActivosAvanzado } from '../../types/filtrosActivosAvanzado.tsx';
import { useParams } from 'react-router-dom';
import type { Persona } from '../../types/persona.tsx';
import type { Usuario } from '../../types/usuario.tsx';
import { getUsuarioPersona, listarUsuarios } from '../../assets/services/usuarioService.tsx';
import TarjetaPersona from '../../components/TarjetaPersona.tsx';

export default function PersonaDetalle() {
    const [activos, setActivos] = useState<ActivoAvanzado[]>([]);
    const [cargandoActivos, setCargandoActivos] = useState(true);
    const [cargandoUsuario, setCargandoUsuario] = useState(true);
    const { id } = (useParams<{ id: string }>());
    const [usuario, setUsuario] = useState<Usuario>();
    useEffect(() => {
            const fetchActivos = async () => {
                setCargandoActivos(true);
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
                    setCargandoActivos(false);
                }
            };
            const fetchInfoPersona= async () => {
                setCargandoUsuario(true);
                try {
                    
                    // Pasamos el texto ingresado como parámetro "filtroTexto" al backend
                    if(!id){
                        throw new Error("id inexistente")
                    }
                    const respuesta = await getUsuarioPersona(parseInt(id))
                    console.log("Persona recibida: "+JSON.stringify(respuesta))
                    if (respuesta.data) {
                        setUsuario(respuesta.data);
                    }
                } catch (error) {
                    console.error("Error al buscar activos:", error);
                } finally {
                    setCargandoActivos(false);
                }
            }
            
        // Un simple "debounce" para no saturar la BD en cada pulsación de tecla
        fetchActivos()
        fetchInfoPersona()
        
    }, []);
    return(
        <>
            <h1>Detalle Persona</h1>
            <TarjetaPersona
                PersonaData={usuario}/>
            <ResultadosBusqueda 
                results={activos}
                loading={cargandoActivos}
                                
            />
        </>
    )
}