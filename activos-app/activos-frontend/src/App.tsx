import { BrowserRouter as Router, Routes, Route } from "react-router-dom";

import Login from "./pages/Login.tsx";
import Main from "./pages/Main.tsx";
import BuscadorActivos from './pages/BuscadorActivos';
import Activo from "./pages/Activo.tsx";
import ProtectedRoute from "./auth/ProtectedRoute";
import Layout from './components/Layout.tsx';

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
            <Route path="/ubicaciones" element={<h2>Catálogo de Ubicaciones (En construcción)</h2>} />
          </Route>
        </Route> 
      </Routes>
    </Router>
  )
}

export default App; 