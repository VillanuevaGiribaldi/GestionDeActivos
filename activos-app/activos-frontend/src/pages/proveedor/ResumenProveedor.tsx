
import {
    Table, TableBody, TableCell, TableContainer,
    TableHead, TableRow, Paper
} from "@mui/material";
import { Link, useNavigate } from "react-router-dom";
import type { DetalleItemProveedor } from "@/types/proveedor";

interface Props {
    results: DetalleItemProveedor[];
    loading: boolean;
}

function formatFecha(fecha: string): string {
    if (!fecha || fecha === "-") return "-";

    const date = new Date(fecha);

    if (isNaN(date.getTime())) return "-";

    return date.toLocaleString("es-AR", {
        dateStyle: "short",
        timeStyle: "short"
    });
}

export default function DetalleProveedor({
    results,
    loading
}: Props) {
    const navigate = useNavigate();
    const totalGastado = results.reduce(
        (total, item) => total + item.monto,
        0
    );

    const totalActivos = new Set(
        results.map(item => item.idActivo)
    ).size;


    return (
        <TableContainer component={Paper}>
            <Table stickyHeader size="small">
                <TableHead>
                    <TableRow>
                        <TableCell><strong>Activo</strong></TableCell>
                        <TableCell><strong>Tipo</strong></TableCell>
                        <TableCell align="right"><strong>Monto</strong></TableCell>
                        <TableCell><strong>Fecha de envío</strong></TableCell>
                        <TableCell><strong>Fecha de devolución</strong></TableCell>
                    </TableRow>
                </TableHead>

                <TableBody>
                    {loading ? (
                        <TableRow>
                            <TableCell colSpan={5} align="center">
                                Buscando...
                            </TableCell>
                        </TableRow>
                    ) : results.length === 0 ? (
                        <TableRow>
                            <TableCell colSpan={5} align="center">
                                No se encontraron resultados
                            </TableCell>
                        </TableRow>
                    ) : (
                        
                        results.map((item) => {
                            const idDetalle = item.tipo === "Factura"
                                ? item.idFactura
                                : item.idMantenimiento;

                            const rutaDetalle = item.tipo === "Factura"
                                ? `/factura/${idDetalle}`
                                : `/mantenimiento/${idDetalle}`;

                            return (
                                <TableRow
                                    key={`${item.tipo}-${idDetalle}-${item.idActivo}`}
                                    
                                >
                                    <TableCell
                                    title={`Ir a ${item.tipo.toLowerCase()}...`}
                                    onClick={() => {if (idDetalle !== null) {navigate(rutaDetalle);}}}
                                    sx={{ cursor: "pointer" }}
                                    >{item.tipo}</TableCell>

                                    <TableCell
                                    title={`Ir al activo...`}
                                    onClick={() => {
                                            navigate(`/activo/${item.idActivo}`);
                                    }}
                                    sx={{ cursor: "pointer" }}
                                    >
                                        {item.nombre}
                                    </TableCell>
                                    <TableCell align="right"
                                        title={`Ir a ${item.tipo.toLowerCase()}...`}
                                        onClick={() => {if (idDetalle !== null) {navigate(rutaDetalle);}}}
                                        sx={{ cursor: "pointer" }}
                                    >
                                        {item.monto}
                                    </TableCell>

                                    <TableCell
                                        title={`Ir a ${item.tipo.toLowerCase()}...`}
                                        onClick={() => {if (idDetalle !== null) {navigate(rutaDetalle);}}}
                                        sx={{ cursor: "pointer" }}
                                    >
                                        {formatFecha(item.fechaEnvio)}
                                    </TableCell>

                                    <TableCell
                                        title={`Ir a ${item.tipo.toLowerCase()}...`}
                                        onClick={() => {if (idDetalle !== null) {navigate(rutaDetalle);}}}
                                        sx={{ cursor: "pointer" }}
                                    >
                                        {formatFecha(item.fechaDevolucion)}
                                    </TableCell>
                                </TableRow>
                            );
                        })
                    )
                    
                    }
                    
                    
                </TableBody>
                
            </Table>
            
        </TableContainer>
    );
}
