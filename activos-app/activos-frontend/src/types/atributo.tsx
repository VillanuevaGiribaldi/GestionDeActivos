export interface Atributo {
    idAtributo: number;
    idTipo: number;
    nombre: string;
    porDefecto: string | null;
    obligatorio: boolean | number;
}