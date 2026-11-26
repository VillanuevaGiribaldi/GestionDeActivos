
import { useState } from "react";
import { IconButton, Collapse, Box } from "@mui/material";
import SearchIcon from "@mui/icons-material/Search";
import CloseIcon from "@mui/icons-material/Close";

import BarraBusqueda from "./BarraBusquedaTexto";

interface BotonBusquedaProps {
    buscando: boolean;
    onChangeBuscando: (value: boolean) => void;
}

export default function BotonBusqueda({
    buscando,
    onChangeBuscando
}: BotonBusquedaProps) {



    return (
        <Box sx={{ position: "relative" ,
            
        }}>
            <IconButton
                onClick={() => onChangeBuscando(!buscando)}
                aria-label={buscando ? "Cerrar búsqueda" : "Abrir búsqueda"}
                sx={{color:"white"}}
                
            >
                {buscando ? <CloseIcon  sx={{fontSize:30}}/> : <SearchIcon sx={{fontSize:30}}/>}
            </IconButton>
        </Box>
    );
}
