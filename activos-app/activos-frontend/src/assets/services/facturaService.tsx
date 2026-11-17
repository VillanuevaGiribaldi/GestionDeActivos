import { apiRequest } from "../../api/client";
import type { Factura } from "../../types/factura";
import type { apiResponse } from "../../types/apiResponse";

export const listarFacturas = (params?: Record<string, string | number>) => {
    const queryString = params 
        ? '?' + new URLSearchParams(params as Record<string, string>).toString() 
        : '';
        
    return apiRequest<apiResponse<Factura[]>>(`/factura${queryString}`, {
        method: "GET"
    });
};