import { apiRequest } from "../../api/client";
import type { ComposicionTipo } from "../../types/composicionTipo";
import type { apiResponse } from "../../types/apiResponse";

export const listarComponentesDe = (idTipoPadre: number) => {
    return apiRequest<apiResponse<ComposicionTipo[]>>(`/composicion/padre/${idTipoPadre}`, {
        method: "GET",
    });
};

export interface NuevaComposicionPayload {
    nombreTipoPadre: string;
    nombreTipoComponente: string;
    cantidadComponentesMaxima: number | null;
}

export const crearComposicion = (datos: NuevaComposicionPayload) => {
    return apiRequest<apiResponse<unknown>>(`/composicion/nuevo`, {
        method: "POST",
        body: JSON.stringify({ composicion: datos }),
    });
};

export const eliminarComposicion = (idTipoPadre: number, idTipoComponente: number) => {
    return apiRequest<apiResponse<unknown>>(
        `/composicion/${idTipoPadre}/${idTipoComponente}`,
        { method: "DELETE" }
    );
};