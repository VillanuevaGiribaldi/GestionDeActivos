import {
    Autocomplete,
    TextField
} from "@mui/material";

import type { valorIdNombre } from "@/types/ValorIdNombre";

interface Props {
    label: string;
    opciones: valorIdNombre[];
    value?: number;
    onChange: (value: number | undefined) => void;
}

export default function Autocompletar({
    label,
    opciones,
    value,
    onChange
}: Props) {
    const opcionSeleccionada =
        opciones.find(opcion => opcion.id === value) ?? null;
    return (
        <Autocomplete
            fullWidth
            size="small"
            options={opciones}
            value={opcionSeleccionada}
            getOptionLabel={(opcion) => opcion.nombre}
            getOptionKey={(opcion)=> opcion.id}
            isOptionEqualToValue={(opcion, valor) =>
                opcion.id === valor.id
            }
            onChange={(_, nuevaOpcion) =>
                onChange(nuevaOpcion?.id)
            }
            renderInput={(params) => (
                <TextField
                    
                    {...params}
                    label={label}
                    placeholder="Buscar..."
                />
            )}
            noOptionsText="No se encontraron resultados"
        />
    );
}