import { Outlet } from "react-router-dom";
import Sidebar from "./Sidebar";
import { Box } from "@mui/material";
import Header from "./Header";
import { useState } from "react";
export default function Layout() {
    const [abierto, setAbierto] = useState(false);

    return (
        <Box sx={{ display: 'flex', minHeight: '100vh', backgroundColor: '#f9fafb' }}>
            <Sidebar 
                buscando={abierto}
                onChangeBuscando={setAbierto}
            />
            
            <Box component="main" sx={{ flexGrow: 1, p: 3, width: { sm: `calc(100% - 240px)`} }}>
                {/* <Outlet /> es el "agujero" donde React Router inyectará la página que corresponda */}
                {abierto && (
                    <Header abierto={abierto} />
                )}
                <Outlet />
            </Box>
        </Box>
    );
}