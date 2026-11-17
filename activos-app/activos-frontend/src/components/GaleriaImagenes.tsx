import { useEffect, useState } from 'react';
import { listarImagenes } from '../assets/services/imagenService';
import type { Imagen } from '../types/imagen';
import InsertPhotoIcon from '@mui/icons-material/InsertPhoto';

export default function GaleriaImagenes({ idActivo }: { idActivo: number }) {
    const [imagenes, setImagenes] = useState<Imagen[]>([]);
    const [cargando, setCargando] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const fetchImagenes = async () => {
            try {
                const respuesta = await listarImagenes({ idActivo });
                
                if (respuesta.error) {
                    setError(respuesta.error);
                } else {
                    const dataObtenida = (respuesta as any).imagenes || respuesta.data || [];
                    setImagenes(dataObtenida);
                }
            } catch (err) {
                setError(err instanceof Error ? err.message : "Error al cargar las imágenes");
            } finally {
                setCargando(false);
            }
        };

        if (idActivo) fetchImagenes();
    }, [idActivo]);

    if (error) return <div className="text-red-500 text-sm p-4">{error}</div>;
    if (cargando) return <div className="text-gray-500 text-sm p-4 animate-pulse">Cargando galería visual...</div>;
    if (imagenes.length === 0) return (
        <div className="flex flex-col items-center justify-center p-8 text-gray-400 border-2 border-dashed rounded-lg bg-gray-50">
            <InsertPhotoIcon sx={{ fontSize: 40, mb: 1 }} />
            <p>No hay imágenes registradas para este activo.</p>
        </div>
    );

    return (
        <div className="space-y-4 mt-6">
            <h3 className="text-xl font-bold text-gray-800 border-b pb-2">Registro Fotográfico</h3>
            
            {/* GRID VISUAL TIPO "ICONOS GRANDES" */}
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                {imagenes.map((img) => (
                    <div 
                        key={img.idImagen} 
                        className="group relative bg-white border border-gray-200 rounded-lg shadow-sm hover:shadow-md transition-shadow overflow-hidden flex flex-col"
                    >
                        {/* Contenedor de la Imagen */}
                        <div className="aspect-square w-full bg-gray-100 flex items-center justify-center overflow-hidden">
                            <img 
                                src={img.ruta} 
                                alt={img.descripcion || `Imagen ${img.idImagen}`} 
                                className="object-cover w-full h-full"
                                onError={(e) => {
                                    // Si la ruta se rompe, mostramos un icono genérico
                                    (e.target as HTMLImageElement).style.display = 'none';
                                    (e.target as HTMLImageElement).nextElementSibling?.classList.remove('hidden');
                                }}
                            />
                            {/* Fallback Icon */}
                            <div className="hidden text-gray-400">
                                <InsertPhotoIcon sx={{ fontSize: 48 }} />
                            </div>
                        </div>

                        {/* Pie de foto / Metadatos */}
                        <div className="p-3 text-sm flex-1 flex flex-col justify-between">
                            <p className="text-gray-700 font-medium line-clamp-2" title={img.descripcion || "Sin descripción"}>
                                {img.descripcion || "Sin descripción"}
                            </p>
                            <p className="text-xs text-gray-400 mt-2">
                                {new Date(img.fecha).toLocaleDateString('es-AR')}
                            </p>
                            
                            {/* Etiqueta de estado en la esquina superior si está dada de baja */}
                            {img.estado === 'I' && (
                                <span className="absolute top-2 right-2 bg-red-100 text-red-700 text-xs font-bold px-2 py-1 rounded shadow-sm opacity-90">
                                    Descartada
                                </span>
                            )}
                        </div>
                    </div>
                ))}
            </div>
        </div>
    );
}