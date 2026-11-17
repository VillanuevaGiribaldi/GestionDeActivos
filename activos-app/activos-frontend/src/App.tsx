import { BrowserRouter as Router, Routes, Route } from "react-router-dom";

import Login from "./pages/Login.tsx";
import Main from "./pages/Main.tsx";
import BuscadorActivos from './pages/BuscadorActivos';
import Activo from "./pages/Activo.tsx";
import ProtectedRoute from "./auth/ProtectedRoute";
import Layout from './components/Layout.tsx';
import Ubicaciones from './pages/Ubicaciones';
import Proveedores from './pages/Proveedores';
import Activos from './pages/Activos';
import Personas from "./pages/Personas.tsx";
import Marcas from "./pages/Marcas.tsx";
import Tipos from "./pages/Tipos.tsx";
import Usuarios from "./pages/Usuarios.tsx";
import Estados from './pages/Estados';
import Facturas from "./pages/Factura.tsx";
import Mantenimientos from "./pages/Mantenimiento.tsx";
import Imagenes from "./pages/Imagenes.tsx";

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
            <Route path="/activos" element={<Activos />} />
            <Route path="/ubicaciones" element={<Ubicaciones />} />
            <Route path="/proveedores" element={<Proveedores />} />
            <Route path="/personas" element={<Personas />} />
            <Route path="/marcas" element={<Marcas />} />
            <Route path="/tipos" element={<Tipos />} />
            <Route path="/usuarios" element={<Usuarios />} />
            <Route path="/estados" element={<Estados />} />
            <Route path="/facturas" element={<Facturas />} />
            <Route path="/mantenimientos" element={<Mantenimientos />} />
            <Route path="/imagenes" element={<Imagenes />} />
          </Route>
        </Route> 
      </Routes>
    </Router>
  )
}

export default App; 