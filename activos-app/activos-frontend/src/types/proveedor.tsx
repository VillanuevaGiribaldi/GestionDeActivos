export interface Proveedor {
    idProveedor: number;
    nombre: string;
    direccion: string;
    telefono: string;
    mail: string;
    descripcion: string;
    estado: string;
}
export interface DetalleItemProveedor {
    tipo: "Factura" | "Mantenimiento";
    idActivo: number;
    nombre: string;
    monto: number;
    fechaEnvio: string;
    fechaDevolucion: string;
    idFactura: number | null;
    idMantenimiento: number | null;
}