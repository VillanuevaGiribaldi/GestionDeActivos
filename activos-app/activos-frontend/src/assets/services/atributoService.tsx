import { apiRequest } from "../../api/client";
import type { Atributo } from "../../types/atributo";
import type { apiResponse } from "../../types/apiResponse";

export const listarAtributos = (idTipo?: number) => {
    const queryString = idTipo !== undefined ? `?idTipo=${idTipo}` : "";
    return apiRequest<apiResponse<Atributo[]>>(`/atributo${queryString}`, {
        method: "GET",
    });
};

export const getAtributo = (idAtributo: number) => {
    return apiRequest<apiResponse<Atributo>>(`/atributo/${idAtributo}`, {
        method: "GET",
    });
};

export interface AtributoPayload {
    idTipo: number;
    nombre: string;
    porDefecto: string | null;
    obligatorio: boolean;
}

export const crearAtributo = (datos: AtributoPayload) => {
    return apiRequest<apiResponse<{ idAtributo: number }>>(`/atributo/nuevo`, {
        method: "POST",
        body: JSON.stringify({ atributo: datos }),
    });
};

export const modificarAtributo = (idAtributo: number, datos: AtributoPayload) => {
    return apiRequest<apiResponse<unknown>>(`/atributo/${idAtributo}`, {
        method: "PUT",
        body: JSON.stringify({
            atributo: {
                idAtributo,
                ...datos,
            },
        }),
    });
};

export const eliminarAtributo = (idAtributo: number) => {
    return apiRequest<apiResponse<unknown>>(`/atributo/${idAtributo}`, {
        method: "DELETE",
    });
};