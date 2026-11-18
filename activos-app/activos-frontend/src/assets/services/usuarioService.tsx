import { apiRequest } from "../../api/client";
import type { Usuario } from "../../types/usuario";
import type { apiResponse } from "../../types/apiResponse";

export const listarUsuarios = (params?: Record<string, string | number>) => {
    const queryString = params 
        ? '?' + new URLSearchParams(params as Record<string, string>).toString() 
        : '';
        
    return apiRequest<apiResponse<Usuario[]>>(`/usuario${queryString}`, {
        method: "GET"
    });
};
export const getUsuario = (id: number) => {
    if(!id) throw new Error("Id invalido");
           
    return apiRequest<apiResponse<Usuario>>(`/usuario/${id}`, {
        method: "GET"
    });
}
export const getUsuarioPersona = (id: number) => {
    if(!id) throw new Error("Id invalido");
           
    return apiRequest<apiResponse<Usuario>>(`/persona/${id}/usuario`, {
        method: "GET"
    });
}