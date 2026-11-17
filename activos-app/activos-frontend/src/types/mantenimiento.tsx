export interface Mantenimiento {
    idMantenimiento: number;
    fallaReportada: string;
    fechaEnvio: string;
    reparacionRealizada: string | null;
    fechaDevolucion: string | null;
    costoTotal: number | null;
    idActivo: number;
    nombreActivo: string;
    numeroSerie: string;
    idProveedor: number;
    nombreProveedor: string;
}