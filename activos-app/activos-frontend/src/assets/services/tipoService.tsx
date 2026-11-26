import { apiRequest } from "../../api/client";
import type { Tipo } from "../../types/tipo";
import type { apiResponse } from "../../types/apiResponse";

export const listarTipos = (params?: Record<string, string | number>) => {
    const queryString = params 
        ? '?' + new URLSearchParams(params as Record<string, string>).toString() 
        : '';
        
    return apiRequest<apiResponse<Tipo[]>>(`/tipo${queryString}`, {
        method: "GET"
    });
};
export interface NuevoTipoPayload {
    nombre: string;
    descripcion?: string;
    estado?: string;
}

export interface ModificarTipoPayload {
    nombre: string;
    descripcion?: string;
}

export const crearTipo = (datos: NuevoTipoPayload) => {
    return apiRequest<apiResponse<unknown>>(`/tipo/nuevo`, {
        method: "POST",
        body: JSON.stringify({
            tipo: {
                ...datos,
                estado: datos.estado || "A",
            },
        }),
    });
};

export const modificarTipo = (idTipo: number, datos: ModificarTipoPayload) => {
    return apiRequest<apiResponse<unknown>>(`/tipo/${idTipo}`, {
        method: "PUT",
        body: JSON.stringify({
            tipo: {
                idTipo,
                nombre: datos.nombre,
                descripcion: datos.descripcion ?? "",
            },
        }),
    });
};

export const bajaTipo = (idTipo: number) => {
    return apiRequest<apiResponse<unknown>>(`/tipo/${idTipo}`, {
        method: "DELETE",
    });
};

export const altaTipo = (idTipo: number) => {
    return apiRequest<apiResponse<unknown>>(`/tipo/${idTipo}/alta`, {
        method: "PUT",
    });
};