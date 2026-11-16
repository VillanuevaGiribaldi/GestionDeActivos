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