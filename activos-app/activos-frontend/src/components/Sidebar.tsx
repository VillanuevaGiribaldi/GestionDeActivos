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
import BallotIcon from '@mui/icons-material/Ballot';
import LocationOnIcon from '@mui/icons-material/LocationOn';
import StoreIcon from '@mui/icons-material/Store';
import InventoryIcon from '@mui/icons-material/Inventory';
import PeopleIcon from '@mui/icons-material/People';
import LocalOfferIcon from '@mui/icons-material/LocalOffer';
import CategoryIcon from '@mui/icons-material/Category';
import AdminPanelSettingsIcon from '@mui/icons-material/AdminPanelSettings';
import FactCheckIcon from '@mui/icons-material/FactCheck';
import ReceiptIcon from '@mui/icons-material/Receipt';
import EngineeringIcon from '@mui/icons-material/Engineering';
import PhotoLibraryIcon from '@mui/icons-material/PhotoLibrary';
import HistoryIcon from '@mui/icons-material/History'

import { useNavigate } from 'react-router-dom';


const drawerWidth = 240;

export default function Sidebar() {
    const location = useLocation();
    const navigate = useNavigate();
    {console.log(location.pathname)}
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
                <Typography variant="h6" noWrap component="div" sx={{ fontWeight: 'bold' }} 
                    onClick={() => navigate(`/`)}
                    style={{ cursor: 'pointer' }}
                    >
                    ITAM System
                </Typography>
            </Toolbar>
            
            <Box sx={{ overflow: 'auto', mt: 2 }}>
                <List>
                    
                    {/* Botones del Catálogo*/}
                    <ListItem disablePadding>
                        <ListItemButton 
                            component={Link} 
                            to="/"
                            selected={location.pathname==('/')}
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
                                <BallotIcon />
                            </ListItemIcon>
                            <ListItemText primary="Resumen" />
                        </ListItemButton>
                    </ListItem>
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
                            to="/historial"
                            selected={location.pathname.startsWith('/historial')}
                            sx={{
                                '&.Mui-selected': { backgroundColor: '#334155', borderLeft: '4px solid #3b82f6' },
                                '&:hover': { backgroundColor: '#334155' }
                            }}
                        >
                            <ListItemIcon sx={{ color: 'white' }}>
                                <HistoryIcon />
                            </ListItemIcon>
                            <ListItemText primary="Historial" />
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
                    <ListItem disablePadding>
                        <ListItemButton 
                            component={Link} 
                            to="/personas"
                            selected={location.pathname.startsWith('/personas')}
                            sx={{
                                '&.Mui-selected': { backgroundColor: '#334155', borderLeft: '4px solid #3b82f6' },
                                '&:hover': { backgroundColor: '#334155' }
                            }}
                        >
                            <ListItemIcon sx={{ color: 'white' }}>
                                <PeopleIcon />
                            </ListItemIcon>
                            <ListItemText primary="Personas" />
                        </ListItemButton>
                    </ListItem>
                    <ListItem disablePadding>
                        <ListItemButton 
                            component={Link} 
                            to="/marcas"
                            selected={location.pathname.startsWith('/marcas')}
                            sx={{
                                '&.Mui-selected': { backgroundColor: '#334155', borderLeft: '4px solid #3b82f6' },
                                '&:hover': { backgroundColor: '#334155' }
                            }}
                        >
                            <ListItemIcon sx={{ color: 'white' }}>
                                <LocalOfferIcon />
                            </ListItemIcon>
                            <ListItemText primary="Marcas" />
                        </ListItemButton>
                    </ListItem>
                    <ListItem disablePadding>
                        <ListItemButton 
                            component={Link} 
                            to="/tipos"
                            selected={location.pathname.startsWith('/tipos')}
                            sx={{
                                '&.Mui-selected': { backgroundColor: '#334155', borderLeft: '4px solid #3b82f6' },
                                '&:hover': { backgroundColor: '#334155' }
                            }}
                        >
                            <ListItemIcon sx={{ color: 'white' }}>
                                <CategoryIcon />
                            </ListItemIcon>
                            <ListItemText primary="Tipos" />
                        </ListItemButton>
                    </ListItem>
                    <ListItem disablePadding>
                        <ListItemButton 
                            component={Link} 
                            to="/usuarios"
                            selected={location.pathname.startsWith('/usuarios')}
                            sx={{
                                '&.Mui-selected': { backgroundColor: '#334155', borderLeft: '4px solid #3b82f6' },
                                '&:hover': { backgroundColor: '#334155' }
                            }}
                        >
                            <ListItemIcon sx={{ color: 'white' }}>
                                <AdminPanelSettingsIcon />
                            </ListItemIcon>
                            <ListItemText primary="Usuarios" />
                        </ListItemButton>
                    </ListItem>
                    <ListItem disablePadding>
                        <ListItemButton 
                            component={Link} 
                            to="/estados"
                            selected={location.pathname.startsWith('/estados')}
                            sx={{
                                '&.Mui-selected': { backgroundColor: '#334155', borderLeft: '4px solid #3b82f6' },
                                '&:hover': { backgroundColor: '#334155' }
                            }}
                        >
                            <ListItemIcon sx={{ color: 'white' }}>
                                <FactCheckIcon />
                            </ListItemIcon>
                            <ListItemText primary="Estados" />
                        </ListItemButton>
                    </ListItem>
                    <ListItem disablePadding>
                        <ListItemButton 
                            component={Link} 
                            to="/facturas"
                            selected={location.pathname.startsWith('/facturas')}
                            sx={{
                                '&.Mui-selected': { backgroundColor: '#334155', borderLeft: '4px solid #3b82f6' },
                                '&:hover': { backgroundColor: '#334155' }
                            }}
                        >
                            <ListItemIcon sx={{ color: 'white' }}>
                                <ReceiptIcon />
                            </ListItemIcon>
                            <ListItemText primary="Facturas" />
                        </ListItemButton>
                    </ListItem>
                    <ListItem disablePadding>
                        <ListItemButton 
                            component={Link} 
                            to="/mantenimientos"
                            selected={location.pathname.startsWith('/mantenimientos')}
                            sx={{
                                '&.Mui-selected': { backgroundColor: '#334155', borderLeft: '4px solid #3b82f6' },
                                '&:hover': { backgroundColor: '#334155' }
                            }}
                        >
                            <ListItemIcon sx={{ color: 'white' }}>
                                <EngineeringIcon />
                            </ListItemIcon>
                            <ListItemText primary="Mantenimientos" />
                        </ListItemButton>
                    </ListItem>
                    <ListItem disablePadding>
                        <ListItemButton 
                            component={Link} 
                            to="/imagenes"
                            selected={location.pathname.startsWith('/imagenes')}
                            sx={{
                                '&.Mui-selected': { backgroundColor: '#334155', borderLeft: '4px solid #3b82f6' },
                                '&:hover': { backgroundColor: '#334155' }
                            }}
                        >
                            <ListItemIcon sx={{ color: 'white' }}>
                                <PhotoLibraryIcon />
                            </ListItemIcon>
                            <ListItemText primary="Imágenes" />
                        </ListItemButton>
                    </ListItem>
                </List>
            </Box>
        </Drawer>
    );
}