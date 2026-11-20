import { apiRequest } from "../../api/client";
import type { Historial } from "../../types/historial";
import type { apiResponse } from "../../types/apiResponse";

export const listarHistorial = (params?: Record<string, string | number>) => {
    const queryString = params
        ? '?' + new URLSearchParams(params as Record<string, string>).toString()
        : '';

    return apiRequest<apiResponse<Historial[]>>(`/historial${queryString}`, {
        method: "GET"
    });
};

export const listarHistorialActivo = (idActivo: number) => {
    return apiRequest<apiResponse<Historial[]>>(`/historial/activo/${idActivo}`, {
        method: "GET"
    });
};