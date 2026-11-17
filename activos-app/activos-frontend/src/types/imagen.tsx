export interface Imagen {
    idImagen: number;
    idActivo: number;
    ruta: string;
    estado: string;
    fecha: string;
    descripcion: string | null;
    nombreActivo?: string;
}