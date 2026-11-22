import { BrowserRouter as Router, Routes, Route } from "react-router-dom";

import Login from "./pages/Login.tsx";
import Main from "./pages/Main.tsx";
import BuscadorActivos from './pages/activo/BuscadorActivos';

import Activo from "./pages/activo/Activo.tsx";
import ProtectedRoute from "./auth/ProtectedRoute";
import Layout from './components/Layout.tsx';
import Ubicaciones from './pages/Ubicaciones';
import Proveedores from './pages/proveedor/Proveedores.tsx';
import ProveedorDetalle from './pages/proveedor/ProveedorDetalle.tsx';
import Personas from "./pages/persona/Personas.tsx";
import Marcas from "./pages/Marcas.tsx";
import Tipos from "./pages/Tipos.tsx";
import Usuarios from "./pages/usuario/Usuarios.tsx";
import Estados from './pages/Estados';
import Facturas from "./pages/factura/Factura.tsx";
import FacturaDetalle from './pages/factura/FacturaDetalle';
import Mantenimientos from "./pages/mantenimiento/Mantenimiento.tsx";
import MantenimientoDetalle from './pages/mantenimiento/MantenimientoDetalle';
import Imagenes from "./pages/Imagenes.tsx";
import PersonaDetalle from "./pages/persona/personaDetalle.tsx";
import Historial from "./pages/Historial.tsx";

function App() {
  return (
    <Router>
      <Routes>
        {/* Public */}
        <Route path="/login" element={<Login />} />

        {/* Protected */}
        <Route element={<ProtectedRoute />}>
          <Route element={<Layout />}>
            <Route path="/" element={<Main />} />
            <Route path="/activos" element={<BuscadorActivos />} />
            <Route path="/activo/:id" element={<Activo />} />
            
            {/* Ruta para el nuevo módulo auxiliar */}
            <Route path="/ubicaciones" element={<Ubicaciones />} />
            <Route path="/proveedores" element={<Proveedores />} />
            <Route path="/proveedor/:id" element={<ProveedorDetalle />} />
            <Route path="/personas" element={<Personas />} />
            <Route path="/persona/:id" element={<PersonaDetalle />} />

            <Route path="/marcas" element={<Marcas />} />
            <Route path="/tipos" element={<Tipos />} />
            <Route path="/usuarios" element={<Usuarios />} />
            <Route path="/estados" element={<Estados />} />
            <Route path="/facturas" element={<Facturas />} />
            <Route path="/factura/:id" element={<FacturaDetalle />} />
            <Route path="/mantenimientos" element={<Mantenimientos />} />
            <Route path="/mantenimiento/:id" element={<MantenimientoDetalle />} />
            <Route path="/imagenes" element={<Imagenes />} />
            <Route path="/historial" element={<Historial />} />
          </Route>
        </Route> 
      </Routes>
    </Router>
  )
}

export default App; 