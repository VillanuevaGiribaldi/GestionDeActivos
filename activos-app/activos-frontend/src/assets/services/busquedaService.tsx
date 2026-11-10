import { apiRequest } from "../../api/client";
import type { ActivoAvanzado } from "../../types/activoAvanzado";
import type { apiResponse } from "../../types/apiResponse";

export const buscarActivos = (params?: Record<string, string | number>) => {
    // Convertimos el objeto params en una cadena de texto para la URL
    const queryParams = params 
        ? '?' + new URLSearchParams(params as Record<string, string>).toString() 
        : '';
        
    return apiRequest<apiResponse<ActivoAvanzado[]>>(`/activo${queryParams}`, {
        method: "GET"
    });
};