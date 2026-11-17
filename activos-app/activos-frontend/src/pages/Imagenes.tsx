import { useEffect, useState } from 'react';
import { listarImagenes } from '../assets/services/imagenService';
import type { Imagen } from '../types/imagen';
import InsertPhotoIcon from '@mui/icons-material/InsertPhoto';
import { Chip } from "@mui/material";

export default function Imagenes() {
    const [imagenes, setImagenes] = useState<Imagen[]>([]);
    const [cargando, setCargando] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const fetchImagenes = async () => {
            try {
                // Al no enviar parámetros, listará todas las imágenes del sistema
                const respuesta = await listarImagenes();
                
                if (respuesta.error) {
                    setError(respuesta.error);
                } else {
                    const dataObtenida = (respuesta as any).imagenes || respuesta.data || [];
                    setImagenes(dataObtenida);
                }
            } catch (err) {
                setError(err instanceof Error ? err.message : "Error al cargar la galería");
            } finally {
                setCargando(false);
            }
        };

        fetchImagenes();
    }, []);

    if (error) return (
        <div className="p-6 text-center text-red-500 font-bold">Error: {error}</div>
    );

    return (
        <div className="p-6 space-y-6">
            <h1 className="text-3xl font-bold text-gray-800 border-b pb-4">
                Imagenes
            </h1>
            
            {cargando ? (
                <div className="flex justify-center p-12">
                    <span className="text-gray-500 animate-pulse text-lg">Cargando biblioteca...</span>
                </div>
            ) : imagenes.length === 0 ? (
                <div className="flex flex-col items-center justify-center p-12 text-gray-400 border-2 border-dashed rounded-lg bg-gray-50">
                    <InsertPhotoIcon sx={{ fontSize: 60, mb: 2 }} />
                    <p className="text-lg">No hay imágenes en el sistema.</p>
                </div>
            ) : (
                <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-6">
                    {imagenes.map((img) => (
                        <div 
                            key={img.idImagen} 
                            className="group relative bg-white border border-gray-200 rounded-lg shadow-sm hover:shadow-md transition-shadow overflow-hidden flex flex-col"
                        >
                            {/* Visualizador de la Foto */}
                            <div className="aspect-square w-full bg-gray-100 flex items-center justify-center overflow-hidden relative">
                                <img 
                                    src={img.ruta} 
                                    alt={img.descripcion || `Imagen ${img.idImagen}`} 
                                    className="object-cover w-full h-full"
                                    onError={(e) => {
                                        (e.target as HTMLImageElement).style.display = 'none';
                                        (e.target as HTMLImageElement).nextElementSibling?.classList.remove('hidden');
                                    }}
                                />
                                {/* Fallback si la URL falla */}
                                <div className="hidden text-gray-400">
                                    <InsertPhotoIcon sx={{ fontSize: 48 }} />
                                </div>
                                
                                {/* Etiqueta superpuesta del estado */}
                                <div className="absolute top-2 right-2">
                                    <Chip 
                                        label={img.estado === 'A' ? 'Vigente' : 'Baja'} 
                                        color={img.estado === 'A' ? 'success' : 'error'}
                                        size="small"
                                    />
                                </div>
                            </div>

                            {/* Metadatos Inferiores */}
                            <div className="p-4 text-sm flex-1 flex flex-col justify-between">
                                <div>
                                    <p className="text-blue-700 font-bold mb-1 truncate" title={img.nombreActivo}>
                                        {img.nombreActivo || `Activo #${img.idActivo}`}
                                    </p>
                                    <p className="text-gray-700 font-medium line-clamp-2" title={img.descripcion || "Sin descripción"}>
                                        {img.descripcion || "Sin descripción"}
                                    </p>
                                </div>
                                <p className="text-xs text-gray-400 mt-3 border-t pt-2">
                                    Fecha: {new Date(img.fecha).toLocaleDateString('es-AR')}
                                </p>
                            </div>
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
}