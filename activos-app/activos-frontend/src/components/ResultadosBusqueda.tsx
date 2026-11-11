import {
    Table, TableBody, TableCell, TableContainer,
    TableHead, TableRow, Paper
} from "@mui/material";
import { Link } from "react-router-dom";

interface SearchResultsProps<T> {
    results: T[];
    loading: boolean;
    onSelect?: (item: T) => void;
}


export default function ResultadosBusqueda<T extends {
    idActivo: number;
    nombreActivo: string;
    tipo: string;
    marca: string;
    numeroSerie?: string | null;
    estado: string;
    ubicacion: string;
}>({
    results,
    loading,
}: SearchResultsProps<T>){


    return(
         <TableContainer component={Paper}>
            <Table stickyHeader size="small">
                <TableHead>
                    <TableRow>
                        <TableCell><strong>ID</strong></TableCell>
                        <TableCell><strong>Activo</strong></TableCell>
                        <TableCell><strong>Tipo</strong></TableCell>
                        <TableCell><strong>Marca</strong></TableCell>
                        <TableCell><strong>Serie</strong></TableCell>
                        <TableCell><strong>Estado</strong></TableCell>
                        <TableCell><strong>Ubicación</strong></TableCell>
                    </TableRow>
                </TableHead>

                <TableBody>
                    {loading ? (
                        <TableRow>
                            <TableCell colSpan={7} align="center">
                                Buscando...
                            </TableCell>
                        </TableRow>
                    ) : results.length === 0 ? (
                        <TableRow>
                            <TableCell colSpan={7} align="center">
                                No se encontraron resultados
                            </TableCell>
                        </TableRow>
                    ) : (
                        results.map((item) => (
                            <TableRow
                                key={item.idActivo}
                                hover
                               
                                component={Link}
                                to={`/activo/${item.idActivo}`}
                                sx={{
                                    cursor: "pointer",
                                    textDecoration: "none",
                                }}
                                
                            >
                                <TableCell>{item.idActivo}</TableCell>
                                <TableCell>{item.nombreActivo}</TableCell>
                                <TableCell>{item.tipo}</TableCell>
                                <TableCell>{item.marca}</TableCell>
                                <TableCell>{item.numeroSerie || "-"}</TableCell>
                                <TableCell>
                                    <span className={`px-2 py-1 rounded text-xs font-bold ${
                                        item.estado === "Operativo"
                                            ? "bg-green-100 text-green-800"
                                            : "bg-gray-100 text-gray-800"
                                    }`}>
                                        {item.estado}
                                    </span>
                                </TableCell>
                                <TableCell>{item.ubicacion}</TableCell>
                            </TableRow>
                        ))
                    )}
                </TableBody>
            </Table>
        </TableContainer>
    );
}