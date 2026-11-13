import { 
    Drawer, 
    List, 
    ListItem, 
    ListItemButton, 
    ListItemIcon, 
    ListItemText, 
    Toolbar, 
    Typography, 
    Box 
} from "@mui/material";
import { Link, useLocation } from "react-router-dom";
import LocationOnIcon from '@mui/icons-material/LocationOn';
import StoreIcon from '@mui/icons-material/Store';
import InventoryIcon from '@mui/icons-material/Inventory';

const drawerWidth = 240;

export default function Sidebar() {
    const location = useLocation();

    return (
        <Drawer
            variant="permanent"
            sx={{
                width: drawerWidth,
                flexShrink: 0,
                [`& .MuiDrawer-paper`]: { 
                    width: drawerWidth, 
                    boxSizing: 'border-box',
                    backgroundColor: '#1e293b', // Fondo oscuro moderno
                    color: 'white'
                },
            }}
        >
            <Toolbar>
                <Typography variant="h6" noWrap component="div" sx={{ fontWeight: 'bold' }}>
                    ITAM System
                </Typography>
            </Toolbar>
            
            <Box sx={{ overflow: 'auto', mt: 2 }}>
                <List>
                    {/* Botones del Catálogo*/}
                    <ListItem disablePadding>
                        <ListItemButton 
                            component={Link} 
                            to="/activos"
                            selected={location.pathname.startsWith('/activos')}
                            sx={{ '&.Mui-selected': { backgroundColor: '#334155', borderLeft: '4px solid #3b82f6' }, '&:hover': { backgroundColor: '#334155' } }}
                        >
                            <ListItemIcon sx={{ color: 'white' }}>
                                <InventoryIcon />
                            </ListItemIcon>
                            <ListItemText primary="Activos" />
                        </ListItemButton>
                    </ListItem>
                    <ListItem disablePadding>
                        <ListItemButton 
                            component={Link} 
                            to="/ubicaciones"
                            selected={location.pathname.startsWith('/ubicaciones')}
                            sx={{
                                '&.Mui-selected': {
                                    backgroundColor: '#334155',
                                    borderLeft: '4px solid #3b82f6'
                                },
                                '&:hover': {
                                    backgroundColor: '#334155'
                                }
                            }}
                        >
                            <ListItemIcon sx={{ color: 'white' }}>
                                <LocationOnIcon />
                            </ListItemIcon>
                            <ListItemText primary="Ubicaciones" />
                        </ListItemButton>
                    </ListItem>
                    <ListItem disablePadding>
                        <ListItemButton 
                            component={Link} 
                            to="/proveedores"
                            selected={location.pathname.startsWith('/proveedores')}
                            sx={{
                                '&.Mui-selected': { backgroundColor: '#334155', borderLeft: '4px solid #3b82f6' },
                                '&:hover': { backgroundColor: '#334155' }
                            }}
                        >
                            <ListItemIcon sx={{ color: 'white' }}>
                                <StoreIcon />
                            </ListItemIcon>
                            <ListItemText primary="Proveedores" />
                        </ListItemButton>
                    </ListItem>
                </List>
            </Box>
        </Drawer>
    );
}