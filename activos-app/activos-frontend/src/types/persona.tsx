//import type { Usuario } from "./usuario";

export interface Persona {
    idPersona: number;
    nombre: string;
    apellido: string;
    dni: string;
    cargo: string | null;
    estado: string;
    //usuario: Usuario | null;
}