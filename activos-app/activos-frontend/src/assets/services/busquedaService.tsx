import { apiRequest } from "../../api/client";
import type { ActivoAvanzado } from "../../types/activoAvanzado";
import type { apiResponse } from "../../types/apiResponse";
import type { FiltrosActivosAvanzado } from "../../types/filtrosActivosAvanzado";

export const buscarActivos = (filtros: FiltrosActivosAvanzado | null) => {
    // Convertimos el objeto params en una cadena de texto para la URL
   
    return apiRequest<apiResponse<ActivoAvanzado[]>>(`/activo`, {
        method: "POST",
        body: 
            JSON.stringify({
                filtros: filtros
            })
        
    });
};