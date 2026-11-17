export interface FiltrosActivosAvanzado {
    filtroTexto?: string | ""
    idTipo?: number;
    idMarca?: number;
    idUbicacion?: number;
    idEstado?: number;
    idPersona?: number;

    atributoClave?: string;
    atributoValor?: string;

    ordenColumna?: string;
    ordenDireccion?: 'ASC' | 'DESC';

    limit?: number;
    offset?: number;
}