import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { listarFacturas } from '../../assets/services/facturaService';
import type { Factura } from '../../types/factura';
import {
    Table, TableBody, TableCell, TableContainer,
    TableHead, TableRow, Paper, Chip
} from "@mui/material";

export default function Facturas() {
    const navigate = useNavigate();

    const [facturas, setFacturas] = useState<Factura[]>([]);
    const [cargando, setCargando] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const fetchFacturas = async () => {
            try {
                const respuesta = await listarFacturas();
                
                if (respuesta.error) {
                    setError(respuesta.error);
                } else {
                    const dataObtenida = (respuesta as any).facturas || respuesta.data || [];
                    setFacturas(dataObtenida);
                }
            } catch (err) {
                setError(err instanceof Error ? err.message : "Error desconocido");
            } finally {
                setCargando(false);
            }
        };

        fetchFacturas();
    }, []);

    if (error) return (
        <div className="p-6 text-center text-red-500 font-bold">
            Error: {error}
        </div>
    );

    return (
        <div className="p-6 space-y-6">
            <h1 className="text-3xl font-bold text-gray-800">Registro de Facturas</h1>
            
            <TableContainer component={Paper} className="shadow-sm border border-gray-100">
                <Table stickyHeader size="small">
                    <TableHead>
                        <TableRow>
                            <TableCell><strong>ID</strong></TableCell>
                            <TableCell><strong>Nro. Comprobante</strong></TableCell>
                            <TableCell><strong>Fecha</strong></TableCell>
                            <TableCell><strong>Proveedor</strong></TableCell>
                            <TableCell><strong>Monto Total</strong></TableCell>
                            <TableCell><strong>Estado</strong></TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {cargando ? (
                            <TableRow>
                                <TableCell colSpan={6} align="center" className="py-8">
                                    Cargando comprobantes...
                                </TableCell>
                            </TableRow>
                        ) : facturas.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={6} align="center" className="py-8 text-gray-500">
                                    No hay facturas registradas
                                </TableCell>
                            </TableRow>
                        ) : (
                            facturas.map((factura) => (
                                <TableRow 
                                    key={factura.idFactura}
                                    hover
                                    onClick={() => navigate(`/factura/${factura.idFactura}`)}
                                    style={{ cursor: 'pointer' }}
                                >
                                    <TableCell>{factura.idFactura}</TableCell>
                                    <TableCell className="font-medium text-gray-900">
                                        {factura.numero || "-"}
                                    </TableCell>
                                    <TableCell className="text-gray-600">
                                        {new Date(factura.fecha).toLocaleDateString('es-AR')}
                                    </TableCell>
                                    <TableCell className="text-gray-600">
                                        {factura.nombreProveedor || "Proveedor no asignado"}
                                    </TableCell>
                                    <TableCell className="text-gray-900 font-medium">
                                        {factura.moneda} {Number(factura.monto).toLocaleString('es-AR', { minimumFractionDigits: 2 })}
                                    </TableCell>
                                    <TableCell>
                                        <Chip 
                                            label={factura.estado === 'A' ? 'Vigente' : 'Anulada'} 
                                            color={factura.estado === 'A' ? 'success' : 'error'}
                                            size="small"
                                            variant={factura.estado === 'A' ? 'filled' : 'outlined'}
                                        />
                                    </TableCell>
                                </TableRow>
                            ))
                        )}
                    </TableBody>
                </Table>
            </TableContainer>
        </div>
    );
}