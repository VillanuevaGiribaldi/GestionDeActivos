
import { Card, CardContent, Chip, Divider, Typography, Box } from "@mui/material";
import PersonIcon from "@mui/icons-material/Person";
import AdminPanelSettingsIcon from "@mui/icons-material/AdminPanelSettings";

import type { Usuario } from "../types/usuario";

function Campo({ etiqueta, children }: { etiqueta: string; children: React.ReactNode }) {
    return (
        <div>
            <Typography variant="caption" color="text.secondary" sx={{ textTransform: "uppercase" }}>
                {etiqueta}
            </Typography>
            <Typography variant="body1">{children}</Typography>
        </div>
    );
}
function Estado({estado}:{estado:string}){
    return (<Chip
                        label={estado === "A" ? "Activo" : "Inactivo"}
                        color={estado === "A" ? "success" : "default"}
                        size="small"
                        variant={estado === "A" ? "filled" : "outlined"}
                    />)
}

interface TarjetaPersonaProps {
    PersonaData: Usuario | undefined;
}

export default function TarjetaPersona({ PersonaData }: TarjetaPersonaProps){
    if (!PersonaData) {
        return <Typography color="text.secondary">Cargando datos...</Typography>;
    }

    const gridStyle = {
        display: "grid",
        gridTemplateColumns: "repeat(2, minmax(0, 1fr))",
        gap: 2
    };
    return (
         <Card sx={{ borderRadius: 3,mt: 2, mb: 2}}>
            <CardContent sx={{ display: "flex", flexDirection: "column", gap: 2 }}>

                {/* Persona */}
                <Box
                    sx={{
                        display: "flex",
                        alignItems: "center",
                        justifyContent: "space-between",
                        gap: 2
                    }}
                >
                    <Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
                        <PersonIcon />
                        <Typography variant="h6">
                            {PersonaData.nombre} {PersonaData.apellido}
                        </Typography>
                    </Box>

                    <Estado
                        estado={PersonaData.estado}
                    />
                </Box>

                <Box sx={gridStyle}>
                    <Campo etiqueta="DNI">
                        {PersonaData.dni || "—"}
                    </Campo>

                    <Campo etiqueta="Cargo">
                        {PersonaData.cargo || "—"}
                    </Campo>
                </Box>

                {/* Usuario */}
                {PersonaData.idUsuario && (
                    <>
                        <Divider />
                        <Box
                            sx={{
                                display: "flex",
                                alignItems: "center",
                                justifyContent: "space-between",
                                gap: 2
                            }}
                        >
                            <Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
                                <AdminPanelSettingsIcon />
                                <Typography variant="h6">
                                    Usuario del sistema
                                </Typography>
                                
                            </Box>
                            <Estado
                                    estado={PersonaData.estadoUsuario}
                                />
                        </Box>

                        <Box sx={gridStyle}>
                            <Campo etiqueta="Username">
                                {PersonaData.username || "—"}
                            </Campo>

                            <Campo etiqueta="Rol">
                                {PersonaData.rol || "—"}
                            </Campo>
                        </Box>
                    </>
                )}

            </CardContent>
        </Card>
    );
}