import {
    FormControl,
    InputLabel,
    Select,
    MenuItem
} from "@mui/material";

import type { valorIdNombre } from "@/types/ValorIdNombre";

interface Props {
    label: string;
    opciones: valorIdNombre[];
    value?: number;
    onChange: (value: number | undefined) => void;
}

export default function Dropdown({
    label,
    opciones,
    value,
    onChange
}: Props) {
    return (
        <FormControl fullWidth size="small">
            <InputLabel>{label}</InputLabel>

            <Select
                value={value ?? ""}
                label={label}
                onChange={(e) =>
                    onChange(
                        e.target.value ===0
                            ? undefined
                            : Number(e.target.value)
                    )
                }
            >
                {opciones.map((opcion) => (
                    <MenuItem key={opcion.id} value={opcion.id}>
                        {opcion.nombre}
                    </MenuItem>
                ))}
            </Select>
        </FormControl>
    );
}