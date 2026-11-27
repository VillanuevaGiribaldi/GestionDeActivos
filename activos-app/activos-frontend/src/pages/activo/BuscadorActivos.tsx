import { useEffect, useState } from 'react';
//import { useNavigate } from 'react-router-dom';
import { useSearchParams } from 'react-router-dom';
import { buscarActivos } from '../../assets/services/busquedaService';
import type { ActivoAvanzado } from '../../types/activoAvanzado';

// Necesitas instalar iconos si no lo has hecho: npm install @mui/icons-material
import BarraBusqueda from '../../components/BarraBusquedaTexto.tsx';
import ResultadosBusqueda from '../../components/ResultadosBusqueda.tsx';
import type { FiltrosActivosAvanzado } from '../../types/filtrosActivosAvanzado.tsx';
import Filtros from '@/components/Filtros.tsx';

export default function BuscadorActivos() {
    const [activos, setActivos] = useState<ActivoAvanzado[]>([]);
    const [cargando, setCargando] = useState(true);
    const [textoBusqueda, setTextoBusqueda] = useState('');
    
    const [searchParams] = useSearchParams();
    const [filtros, setFiltros] = useState<FiltrosActivosAvanzado>(() => {
        const inicial: FiltrosActivosAvanzado = {};
        const idMarca = searchParams.get('idMarca');
        const idTipo = searchParams.get('idTipo');
        if (idMarca) inicial.idMarca = parseInt(idMarca);
        if (idTipo) inicial.idTipo = parseInt(idTipo);
        return inicial;
    });
    //const navigate = useNavigate();
    // Keep filters in sync if the URL changes while the page is already mounted
    useEffect(() => {
        const idMarca = searchParams.get('idMarca');
        const idTipo = searchParams.get('idTipo');
        setFiltros(prev => ({
            ...prev,
            idMarca: idMarca ? parseInt(idMarca) : undefined,
            idTipo: idTipo ? parseInt(idTipo) : undefined,
        }));
    }, [searchParams]);
    // Efecto para buscar. Se dispara al montar o cuando el usuario tipea
    useEffect(() => {
    let cancelado = false;

        const fetchActivos = async () => {
            setCargando(true);
            try {
                const respuesta = await buscarActivos({
                    ...filtros,
                    filtroTexto: textoBusqueda || undefined,
                });
                if (!cancelado && respuesta.data) {
                    setActivos(respuesta.data);
                }
            } catch (error) {
                console.error('Error al buscar activos:', error);
            } finally {
                if (!cancelado) setCargando(false);
            }
        };
        
        // Un simple "debounce" para no saturar la BD en cada pulsación de tecla
        const delaySearch = setTimeout(fetchActivos, 400);
        return () => {
            clearTimeout(delaySearch)
            cancelado=true
        };
        
    }, [textoBusqueda, filtros]);

    return (
        <div className="p-6 bg-gray-50 min-h-screen">
            <div className="max-w-7xl mx-auto space-y-6">
                <h1 className="text-3xl font-bold text-gray-800">Inventario General</h1>
                
                {/* Barra de Búsqueda Global */}
                <BarraBusqueda 
                    texto={textoBusqueda}
                    onChange={setTextoBusqueda}
                    placeholder='Ingrese el nombre de un activo'
                />

                {/* Filtros */}
                <Filtros
                    filtro={filtros}
                    setFiltros={setFiltros}
                />
                {/* Grilla de Resultados */}
                <ResultadosBusqueda 
                    results={activos}
                    loading={cargando}
                    
                />
            </div>
        </div>
    );
}