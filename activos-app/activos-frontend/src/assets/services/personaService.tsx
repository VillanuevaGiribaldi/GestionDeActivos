import { apiRequest } from "../../api/client";
import type { Persona } from "../../types/persona";
import type { apiResponse } from "../../types/apiResponse";

export const listarPersonas = (params?: Record<string, string | number>) => {
    const queryString = params 
        ? '?' + new URLSearchParams(params as Record<string, string>).toString() 
        : '';
        
    return apiRequest<apiResponse<Persona[]>>(`/persona${queryString}`, {
        method: "GET"
    });
};
export const getPersona = (id: number) => {
    if(!id) throw new Error("Id de persona invalido");
           
    return apiRequest<apiResponse<Persona[]>>(`/persona/${id}`, {
        method: "GET"
    });
}

export interface NuevaPersonaPayload {
    nombre: string;
    apellido: string;
    dni: string | null;
    cargo: string;
    estado?: string;
}

export interface ModificarPersonaPayload {
    nombre: string;
    apellido: string;
    dni: string | null;
    cargo: string;
}

export const crearPersona = (datos: NuevaPersonaPayload) => {
    return apiRequest<apiResponse<unknown>>(`/persona/nueva`, {
        method: "POST",
        body: JSON.stringify({
            persona: {
                ...datos,
                estado: datos.estado || "A",
            },
        }),
    });
};

export const modificarPersona = (idPersona: number, datos: ModificarPersonaPayload) => {
    return apiRequest<apiResponse<unknown>>(`/persona/${idPersona}`, {
        method: "PUT",
        body: JSON.stringify({
            persona: {
                idPersona,
                nombre: datos.nombre,
                apellido: datos.apellido,
                dni: datos.dni,
                cargo: datos.cargo,
            },
        }),
    });
};

export const bajaPersona = (idPersona: number) => {
    return apiRequest<apiResponse<unknown>>(`/persona/${idPersona}`, {
        method: "DELETE",
    });
};

export const altaPersona = (idPersona: number) => {
    return apiRequest<apiResponse<unknown>>(`/persona/${idPersona}/alta`, {
        method: "PUT",
    });
};