import { apiRequest } from "../../api/client";
import type { Activo } from "../../types/activo";
import type { apiResponse } from "../../types/apiResponse";

export const listarActivos = (filtros: JSON) => (
    apiRequest<Activo[]>("/activo",
        {
            method:"GET",
            body: JSON.stringify(filtros)
        }
    )
)
export const getActivo = (id: number) => 
    apiRequest<apiResponse<Activo>>(`/activo/${id}`)









