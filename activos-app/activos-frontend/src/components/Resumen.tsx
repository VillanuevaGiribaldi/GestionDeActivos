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
    
    const columns = Object.keys(data[0]);
    

    return(
        <>
        <TableContainer component={Paper}>
            <Table stickyHeader size="small">
                {/* Header */}
                <TableHead>
                    <TableRow>
                        {columns.map((column) => (
                            <TableCell key={column}>
                                <strong>{labels[column] ?? column}</strong>
                            </TableCell>
                        ))}
                    </TableRow>
                </TableHead>

                {/* Rows */}
                <TableBody>
                    {data.map((row, index) => (
                        <TableRow key={`row-${index}`}>
                            {columns.map((col, colIndex) => (
                                <TableCell key={`cell-${index}-${colIndex}`}>
                                    {row[col] ?? "-"}
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

