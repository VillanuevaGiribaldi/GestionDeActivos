export interface Ubicacion {
    idUbicacion: number;
    nombre: string;
    descripcion: string;
    estado: string;
    idUbicacionPadre: number | null;
    nombreUbicacionPadre: string | null;
}
