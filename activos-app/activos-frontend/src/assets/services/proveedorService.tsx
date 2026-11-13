import { apiRequest } from "../../api/client";
import type { Proveedor } from "../../types/proveedor";
import type { apiResponse } from "../../types/apiResponse";

export const getProveedores = (params?: Record<string, string | number>) => {
    const queryString = params 
        ? '?' + new URLSearchParams(params as Record<string, string>).toString() 
        : '';
        
    return apiRequest<apiResponse<Proveedor[]>>(`/proveedor${queryString}`, {
        method: "GET"
    });
};