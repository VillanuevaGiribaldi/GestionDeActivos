import { apiRequest } from "../../api/client";
import type { ActivoAvanzado } from "../../types/activoAvanzado";
import type { apiResponse } from "../../types/apiResponse";

export const buscarActivos = (filtroTexto: string = "") => {
    // Convertimos el objeto params en una cadena de texto para la URL
   
    return apiRequest<apiResponse<ActivoAvanzado[]>>(`/activo`, {
        method: "POST",
        body: JSON.stringify({ filtros: { filtroTexto } })
    });
};