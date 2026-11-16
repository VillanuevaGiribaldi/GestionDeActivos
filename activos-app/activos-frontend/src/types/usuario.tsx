export interface Usuario {
    idUsuario: number;
    username: string;
    rol: string;
    estado: string;
    
    // Datos de la persona asociada
    idPersona: number;
    nombrePersona: string;
    apellidoPersona: string;
    dniPersona: string;
    cargoPersona: string | null;
}