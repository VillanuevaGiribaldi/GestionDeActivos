import {
    Table,
    TableBody,
    TableCell,
    TableContainer,
    TableHead,
    TableRow,
    Paper
} from "@mui/material";

interface DataTableProps {
    data: Record<string, any>[];
    labels: Record<string, string>;
}


export default function Resumen ({data,labels} : DataTableProps){
    if (!data || data.length === 0) {
        return <p>Datos no disponibles</p>;
    }
    if (!labels ){
        labels = Object.keys(data[0]);
    }

    return(
        <>
        <TableContainer component={Paper}>
            <Table stickyHeader size="small">
                {/* Header */}
                <TableHead>
                    <TableRow>
                        {labels.map((column) => (
                            <TableCell key={column}>
                                <strong>{column}</strong>
                            </TableCell>
                        ))}
                    </TableRow>
                </TableHead>

                {/* Rows */}
                <TableBody>
                    {data.map((row, index) => (
                        <TableRow key={row.idActivo ?? index}>
                            {labels.map((column) => (
                                <TableCell key={column}>
                                    {row[column] ?? "-"}
                                </TableCell>
                            ))}
                        </TableRow>
                    ))}
                </TableBody>
            </Table>
        </TableContainer>
        </>
    )
}