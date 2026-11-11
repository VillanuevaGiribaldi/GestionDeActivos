import { useEffect, useState } from 'react';
import type { ActivosResumen } from '../types/activosResumen';
import Resumen from '../components/Resumen';
import Header from '../components/Header';

import { getResumen } from '../assets/services/resumenService';

function Main() {
    const [dataResumen, setDataResumen] = useState<ActivosResumen[]>([]);
    const [cargandoResumen, setCargandoResumen] = useState(true);
    const [errorResumen, setErrorResumen] = useState<string | null>(null);


    useEffect(() => {
        const fetchResumen = async () => {
            try {
                const respuesta = await getResumen();
                
                if (respuesta.error) {
                    setErrorResumen(respuesta.error);
                } else if (respuesta.data) {
                    setDataResumen(respuesta.data);
                }
            } catch (error) {
                setErrorResumen(error instanceof Error ? error.message : "Error desconocido");
            } finally {
                setCargandoResumen(false);
            }
        };
        
        fetchResumen();
    }, []);

    const columnLabels: Record<string, string> = {
        idActivo: "ID",
        nombre: "Nombre",
        marca: "Marca",
        modelo: "Modelo",
        tipoActivo: "Tipo de activo",
        precio: "Precio",
        estado: "Estado" 
    };
    
    // Vista de Carga
    if (cargandoResumen) {
        return (
            <div className="flex justify-center items-center h-screen bg-gray-50">
                <p className="text-xl text-gray-500 font-semibold animate-pulse">
                    Cargando resumen de activos...
                </p>
            </div>
        );
    }

    // Vista de Error
    if (errorResumen) {
        return (
            <div className="flex justify-center items-center h-screen bg-gray-50">
                <div className="bg-red-50 p-6 rounded-lg border border-red-200 text-center">
                    <p className="text-xl text-red-600 font-bold mb-2">Error de Conexión</p>
                    <p className="text-red-500">{errorResumen}</p>
                </div>
            </div>
        );
    }

    // Vista Principal (Éxito)
    return (
        <div className="p-6 bg-gray-50 min-h-screen">
            <div className="max-w-7xl mx-auto">
                <h1 className="text-3xl font-bold text-gray-800 mb-8">
                    Panel de Control - Inventario IT
                </h1>
                
                <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6 overflow-hidden">
                    
                    <Resumen data={dataResumen} labels={columnLabels} />
                </div>
            </div>
        </div>
    );
}

export default Main;