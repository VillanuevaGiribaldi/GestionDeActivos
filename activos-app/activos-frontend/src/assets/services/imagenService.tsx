import { apiRequest } from "../../api/client";
import type { Imagen } from "../../types/imagen";
import type { apiResponse } from "../../types/apiResponse";

export const listarImagenes = (params?: Record<string, string | number>) => {
    const queryString = params 
        ? '?' + new URLSearchParams(params as Record<string, string>).toString() 
        : '';
        
    return apiRequest<apiResponse<Imagen[]>>(`/imagen${queryString}`, {
        method: "GET"
    });
};