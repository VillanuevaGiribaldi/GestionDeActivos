import { Outlet } from "react-router-dom";
import Sidebar from "./Sidebar";
import { Box } from "@mui/material";

export default function Layout() {
    return (
        <Box sx={{ display: 'flex', minHeight: '100vh', backgroundColor: '#f9fafb' }}>
            <Sidebar />

            <Box component="main" sx={{ flexGrow: 1, p: 3, width: { sm: `calc(100% - 240px)` } }}>
                {/* <Outlet /> es el "agujero" donde React Router inyectará la página que corresponda */}
                <Outlet />
            </Box>
        </Box>
    );
}