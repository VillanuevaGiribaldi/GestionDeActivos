import type { Persona } from "./persona";

export interface Usuario extends Persona {
    idUsuario: number;
    username: string;
    rol: string;
    estado: string;
    // Datos de la persona asociada
}