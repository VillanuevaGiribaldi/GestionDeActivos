import { apiRequest } from "../../api/client";
import type { Marca } from "../../types/marca";
import type { apiResponse } from "../../types/apiResponse";

export const listarMarcas = (params?: Record<string, string | number>) => {
    const queryString = params 
        ? '?' + new URLSearchParams(params as Record<string, string>).toString() 
        : '';
        
    // Hacemos el GET a la ruta base /api/marca
    return apiRequest<apiResponse<Marca[]>>(`/marca${queryString}`, {
        method: "GET"
    });
};