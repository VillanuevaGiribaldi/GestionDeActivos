import { apiRequest } from "../../api/client";
import type { ActivosResumen } from "../../types/activosResumen";
import type { apiResponse } from "../../types/apiResponse";

export const getResumen = () => 
    apiRequest<apiResponse<ActivosResumen[]>>(`/activo/resumen`, {method: "GET"})

