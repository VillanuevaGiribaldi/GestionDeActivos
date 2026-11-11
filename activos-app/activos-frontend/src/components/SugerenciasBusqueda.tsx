import { List, ListItemButton, Paper } from "@mui/material";
import { Link } from "react-router-dom";
import type { ActivoAvanzado } from "../types/activoAvanzado";
interface SearchSuggestionsProps {
    results: ActivoAvanzado[];
    loading: boolean;
}

export default function SugerenciasBusqueda({
    results,
    loading,
}: SearchSuggestionsProps) {
    if (loading || results.length === 0) return null;

    return (
        <Paper
            className="sugerenciasBusquedas"
            elevation={3}
            sx={{
                position: "absolute",
                top: "100%",
                left: 0,
                right: 0,
                zIndex: 10,
                mt: 0.5,
                overflow: "hidden",

                bgcolor: "rgba(37, 37, 37, 0.77)",
                color: "#ffffff",
                backdropFilter: "blur(4px)",
                border: "1px solid rgba(255, 255, 255, 0.1)",


                maxHeight: "300px",
                overflowY: "auto",

                "&::-webkit-scrollbar": {
                    width: "10px",
                },
                "&::-webkit-scrollbar-thumb": {
                    bgcolor: "#888",
                    borderRadius: "4px",
                },
                
            }}
        >
            <List disablePadding>
                {results.map((activo) => (
                    <ListItemButton
                        key={activo.idActivo}
                        component={Link}
                        to={`/activo/${activo.idActivo}`}
                        sx={{ 
                            py: 1.5 
                        }}
                    >
                        {activo.nombreActivo}
                    </ListItemButton>
                ))}
            </List>
        </Paper>
    );
}