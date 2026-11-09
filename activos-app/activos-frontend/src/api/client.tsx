const API_URL = '/api'
import { getToken } from "../auth/auth";
/*
export type  apiResponse<T> = {
    message: string;
    error: string | null;
}|{
    message: string;
    data: T;
}*/

export async function apiRequest<T>(
    endpoint: string,
    options: RequestInit ={}
): Promise<T> {
    const respuesta = await fetch(`${API_URL}${endpoint}`,{
        ...options,
        headers: {
            "Content-Type": "application/json",
            ...options.headers,
            Authorization: `Bearer ${getToken()}`
        }
    })
    

    if(!respuesta||respuesta.status===502){
        throw new Error("No se recibió respuesta de la API")
    }
    const data = await respuesta.json()

    if (!respuesta.ok) {
        const error = new Error(data.error || "Pedido a la API falló");
        error.name = data.message || "API Error";

        throw error;
    }
    return data as T
}