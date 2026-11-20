export interface Historial {
    idHistorial: number;
    fecha: string;
    idActivo?: number;
    nombreActivo?: string;
    numeroSerie?: string | null;
    usuario: string;
    responsable: string;
    accionRealizada: string;
    comentario: string | null;
    estadoAnterior: Record<string, unknown> | null;
    estadoNuevo: Record<string, unknown> | null;
}