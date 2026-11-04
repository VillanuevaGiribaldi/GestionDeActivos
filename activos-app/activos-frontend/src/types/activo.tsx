export interface Valor {
    Atributo: string;
    idAtributo: number;
    valor: string | null;
}

export interface Componente {
    idActivo: number;
    nombre?: string;
    "nombre del activo"?: string; // por si el SP lo devuelve con este alias
    numeroSerie: string | null;
    modelo: string | null;
    tipo: string;
    marca: string;
}

export interface Activo {
    idActivo: number;
    "nombre del activo": string;
    numeroSerie: string | null;
    modelo: string | null;
    precioUnitario: string | null;
    fechaRegistro: string;
    tipo: string;
    idTipo: number;
    marca: string;
    idMarca: number;
    ubicacion: string; // "Sede Central > Oficina IT"
    "Nombre ubicacion": string;
    idUbicacion: number;
    estado: string;
    idEstado: number;
    personaAsignada: string | null;
    valores: Valor[];
    componentes: Componente[];
}

export interface ActivoResponse {
    activo: Activo;
    message: string;
}