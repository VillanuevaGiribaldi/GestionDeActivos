import { apiRequest } from "../../api/client";
import type { Mantenimiento } from "../../types/mantenimiento";
import type { apiResponse } from "../../types/apiResponse";

export const listarMantenimientos = () => {
    // Mantenimientos no usa filtro de estado lógico, trae todo el historial
    return apiRequest<apiResponse<Mantenimiento[]>>(`/mantenimiento`, {
        method: "GET"
    });
};

export const getMantenimiento = (id: number) => {
    return apiRequest<apiResponse<Mantenimiento>>(`/mantenimiento/${id}`, {
        method: "GET"
    });
};