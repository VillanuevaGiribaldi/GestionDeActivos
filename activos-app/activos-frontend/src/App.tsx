import { useState } from 'react'

import { BrowserRouter, Routes, Route } from "react-router-dom";

import Login from "./pages/Login.tsx";
import Main from "./pages/Main.tsx";
import ProtectedRoute from "./auth/ProtectedRoute";
import './App.css'

function App() {
  return (
    <>
      <BrowserRouter>
          <Routes>
              {/* Public */}
              <Route path="/login" element={<Login />} />

              {/* Protected */}
              <Route element={<ProtectedRoute />}>
                  <Route path="/" element={<Main />} />
              </Route>
          </Routes>
      </BrowserRouter>
    </>
  )
}

export default App
