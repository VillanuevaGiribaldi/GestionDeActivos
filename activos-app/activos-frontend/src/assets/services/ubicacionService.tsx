import { apiRequest } from "../../api/client";
import type { Ubicacion } from "../../types/ubicacion";
import type { apiResponse } from "../../types/apiResponse";

export const getUbicaciones = (params?: Record<string, string | number>) => {
    const queryString = params 
        ? '?' + new URLSearchParams(params as Record<string, string>).toString() 
        : '';
        
    return apiRequest<apiResponse<Ubicacion[]>>(`/ubicacion${queryString}`, {
        method: "GET"
    });
};