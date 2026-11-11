import { useEffect, useState } from 'react';
//import { useNavigate } from 'react-router-dom';
import { buscarActivos } from '../assets/services/busquedaService';
import type { ActivoAvanzado } from '../types/activoAvanzado';

// Necesitas instalar iconos si no lo has hecho: npm install @mui/icons-material
import BarraBusqueda from '../components/BarraBusquedaTexto.tsx';
import ResultadosBusqueda from '../components/ResultadosBusqueda.tsx';
export default function BuscadorActivos() {
    const [activos, setActivos] = useState<ActivoAvanzado[]>([]);
    const [cargando, setCargando] = useState(true);
    const [textoBusqueda, setTextoBusqueda] = useState('');
    //const navigate = useNavigate();

    // Efecto para buscar. Se dispara al montar o cuando el usuario tipea
    useEffect(() => {
        const fetchActivos = async () => {
            setCargando(true);
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

                {/* Grilla de Resultados */}
                <ResultadosBusqueda 
                    results={activos}
                    loading={cargando}
                    
                />
            </div>
        </div>
    );
}