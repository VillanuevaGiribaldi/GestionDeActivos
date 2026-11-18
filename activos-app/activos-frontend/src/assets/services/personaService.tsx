import { apiRequest } from "../../api/client";
import type { Persona } from "../../types/persona";
import type { apiResponse } from "../../types/apiResponse";

export const listarPersonas = (params?: Record<string, string | number>) => {
    const queryString = params 
        ? '?' + new URLSearchParams(params as Record<string, string>).toString() 
        : '';
        
    return apiRequest<apiResponse<Persona[]>>(`/persona${queryString}`, {
        method: "GET"
    });
};
export const getPersona = (id: number) => {
    if(!id) throw new Error("Id de persona invalido");
           
    return apiRequest<apiResponse<Persona[]>>(`/persona/${id}`, {
        method: "GET"
    });
}