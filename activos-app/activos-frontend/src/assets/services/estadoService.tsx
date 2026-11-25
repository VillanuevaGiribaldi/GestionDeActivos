import { apiRequest } from "../../api/client";
import type { Estado } from "../../types/estado";
import type { apiResponse } from "../../types/apiResponse";

export const getEstados = (params?: Record<string, string | number>) => {
    const queryString = params 
        ? '?' + new URLSearchParams(params as Record<string, string>).toString() 
        : '';
        
    return apiRequest<apiResponse<Estado[]>>(`/estado${queryString}`, {
        method: "GET"
    });
};

export interface NuevoEstadoPayload {
    nombre: string;
    descripcion?: string;
    estado?: string;
}

export interface ModificarEstadoPayload {
    nombre: string;
    descripcion?: string;
}

export const crearEstado = (datos: NuevoEstadoPayload) => {
    return apiRequest<apiResponse<unknown>>(`/estado/nuevo`, {
        method: "POST",
        body: JSON.stringify({
            estado: {
                ...datos,
                estado: datos.estado || "A",
            },
        }),
    });
};

export const modificarEstado = (idEstado: number, datos: ModificarEstadoPayload) => {
    return apiRequest<apiResponse<unknown>>(`/estado/${idEstado}`, {
        method: "PUT",
        body: JSON.stringify({
            estado: {
                idEstado,
                nombre: datos.nombre,
                descripcion: datos.descripcion ?? "",
            },
        }),
    });
};

export const bajaEstado = (idEstado: number) => {
    return apiRequest<apiResponse<unknown>>(`/estado/${idEstado}`, {
        method: "DELETE",
    });
};

export const altaEstado = (idEstado: number) => {
    return apiRequest<apiResponse<unknown>>(`/estado/${idEstado}/alta`, {
        method: "PUT",
    });
};