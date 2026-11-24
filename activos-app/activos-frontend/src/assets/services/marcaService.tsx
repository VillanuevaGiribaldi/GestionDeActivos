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

export interface NuevaMarcaPayload {
    nombre: string;
    descripcion?: string;
    estado?: string;
}

export const crearMarca = (datos: NuevaMarcaPayload) => {
    return apiRequest<apiResponse<unknown>>(`/marca/nueva`, {
        method: "POST",
        body: JSON.stringify({
            marca: {
                ...datos,
                estado: datos.estado || "A",
            },
        }),
    });
};

export interface ModificarMarcaPayload {
    nombre: string;
    descripcion?: string;
}

export const modificarMarca = (idMarca: number, datos: ModificarMarcaPayload) => {
    return apiRequest<apiResponse<unknown>>(`/marca/${idMarca}`, {
        method: "PUT",
        body: JSON.stringify({
            marca: {
                idMarca,
                nombre: datos.nombre,
                descripcion: datos.descripcion ?? "",
            },
        }),
    });
};

export const bajaMarca = (idMarca: number) => {
    return apiRequest<apiResponse<unknown>>(`/marca/${idMarca}`, {
        method: "DELETE",
    });
};

export const altaMarca = (idMarca: number) => {
    return apiRequest<apiResponse<unknown>>(`/marca/${idMarca}/alta`, {
        method: "PUT",
    });
};