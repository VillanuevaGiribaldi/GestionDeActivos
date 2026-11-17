import { apiRequest } from "../../api/client";
import type { Estado } from "../../types/estado";
import type { apiResponse } from "../../types/apiResponse";

export const getEstados = (params?: Record<string, string | number>) => {
    const queryString = params 
        ? '?' + new URLSearchParams(params as Record<string, string>).toString() 
        : '';
        
    return apiRequest<apiResponse<Estado[]>>(`/estado${queryString}`, {
        method: "GET"
    });
};
