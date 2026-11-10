export interface ActivoAvanzado {
    idActivo: number;
    nombreActivo: string;
    numeroSerie: string;
    modelo: string;
    precioUnitario: number;
    fechaRegistro: string;
    tipo: string;
    marca: string;
    ubicacion: string;
    estado: string;
    personaAsignada: string | null;
    atributosExtra: any; // El JSON dinámico
    totalRegistrosTotales: number; // Función de ventana para paginación
}