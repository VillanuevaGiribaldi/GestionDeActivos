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
          </Route>
        </Route> 
      </Routes>
    </Router>
  )
}

export default App; 