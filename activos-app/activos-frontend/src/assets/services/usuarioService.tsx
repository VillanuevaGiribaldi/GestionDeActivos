import { apiRequest } from "../../api/client";
import type { Usuario } from "../../types/usuario";
import type { apiResponse } from "../../types/apiResponse";

export const getUsuarios = (params?: Record<string, string | number>) => {
    const queryString = params 
        ? '?' + new URLSearchParams(params as Record<string, string>).toString() 
        : '';
        
    return apiRequest<apiResponse<Usuario[]>>(`/usuario${queryString}`, {
        method: "GET"
    });
};