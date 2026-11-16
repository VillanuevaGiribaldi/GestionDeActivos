import { apiRequest } from "../../api/client";
import type { Persona } from "../../types/persona";
import type { apiResponse } from "../../types/apiResponse";

export const getPersonas = (params?: Record<string, string | number>) => {
    const queryString = params 
        ? '?' + new URLSearchParams(params as Record<string, string>).toString() 
        : '';
        
    return apiRequest<apiResponse<Persona[]>>(`/persona${queryString}`, {
        method: "GET"
    });
};