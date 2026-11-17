export interface Factura {
    idFactura: number;
    fecha: string;
    monto: number;
    moneda: string;
    numero: string;
    ruta: string | null;
    estado: string;
    idProveedor: number;
    nombreProveedor: string | null;
}