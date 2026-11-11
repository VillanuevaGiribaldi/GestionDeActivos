import { TextField, InputAdornment } from "@mui/material";
import SearchIcon from "@mui/icons-material/Search";
import { CloseRounded } from "@mui/icons-material";
import {IconButton} from "@mui/material";

interface barraBusquedaProps {
    texto: string;
    onChange: (value: string) => void;
    placeholder?: string;
}


export default function BarraBusqueda({
    texto,
    onChange,
    placeholder = "Buscar..."
}: barraBusquedaProps) {
    return (
        <div>
            <TextField
                fullWidth
                variant="outlined"
                placeholder={placeholder}
                value={texto}
                onChange={(e) => onChange(e.target.value)}
                slotProps={{
                    input: {
                        startAdornment: (
                            <InputAdornment position="start">
                                <SearchIcon />
                            </InputAdornment>
                        ),
                        endAdornment:(
                            <InputAdornment position="end">
                                <IconButton
                                    onClick={()=>onChange("")}
                                    edge="end"
                                    disabled={!texto}
                                    size="small"
                                    aria-label="Clear search"
                                >
                                    <CloseRounded />
                                </IconButton>
                                
                            </InputAdornment>
                        )
                    }
                }}
            />
        </div>
    )
}