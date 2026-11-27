import { useEffect, useState } from "react";
import Dropdown from "./Dropdown";
import type { Estado } from "@/types/estado";
import { getEstados } from "@/assets/services/estadoService";
import type { FiltrosActivosAvanzado } from "@/types/filtrosActivosAvanzado";
import { Box,Typography } from "@mui/material";
import Autocompletar from "./Autocompletar";
import type { Tipo } from "@/types/tipo";
import type { Persona } from "@/types/persona";
import type { Ubicacion } from "@/types/ubicacion";
import type { Marca } from "@/types/marca";
import { listarTipos } from "@/assets/services/tipoService";
import { listarPersonas } from "@/assets/services/personaService";
import { getUbicaciones } from "@/assets/services/ubicacionService";
import { listarMarcas } from "@/assets/services/marcaService";

interface filtrosProp{
    filtro: FiltrosActivosAvanzado;
    setFiltros: (filtro: FiltrosActivosAvanzado) => void 
}

export default function Filtros({filtro, setFiltros}:filtrosProp){

    const [estados,setEstados] = useState<Estado[]>([])
    const [tipos, setTipos] = useState<Tipo[]>([]);
    const [personas, setPersonas] = useState<Persona[]>([]);
    const [ubicaciones, setUbicaciones] = useState<Ubicacion[]>([]);
    const [marcas, setMarcas] = useState<Marca[]>([]);

    const [error, setError] = useState<string | null>(null);


    const fetchEstados = async () => {
            //setCargando(true);
            try {
                const respuesta = await getEstados();
                //console.log(JSON.stringify(respuesta))
                if (respuesta.error) {
                    setError(respuesta.error);
                } else {
                    const dataObtenida = respuesta.data || [];
                //console.log(JSON.stringify(dataObtenida))
                    setEstados(dataObtenida);
                }
            } catch (err) {
                setError(err instanceof Error ? err.message : "Error desconocido");
            }
        };
            
        const fetchTipos = async () => {
            try {
                const respuesta = await listarTipos();
                if (respuesta.error) {
                    setError(respuesta.error);
                } else {
                    setTipos(respuesta.data || []);
                }
            } catch (err) {
                setError(err instanceof Error ? err.message : "Error desconocido");
            }
        };

        const fetchPersonas = async () => {
            try {
                const respuesta = await listarPersonas();
                if (respuesta.error) {
                    setError(respuesta.error);
                } else {
                    setPersonas(respuesta.data || []);
                }
            } catch (err) {
                setError(err instanceof Error ? err.message : "Error desconocido");
            }
        };

        const fetchUbicaciones = async () => {
            try {
                const respuesta = await getUbicaciones();
                if (respuesta.error) {
                    setError(respuesta.error);
                } else {
                    setUbicaciones(respuesta.data || []);
                }
            } catch (err) {
                setError(err instanceof Error ? err.message : "Error desconocido");
            }
        };

        const fetchMarcas = async () => {
            try {
                const respuesta = await listarMarcas();

                if (respuesta.error) {
                    setError(respuesta.error);
                } else {
                    setMarcas(respuesta.data || []);
                }
            } catch (err) {
                setError(err instanceof Error ? err.message : "Error desconocido");
            }
        };
    useEffect(() => {
        Promise.all([
            fetchEstados(),
            fetchTipos(),
            fetchPersonas(),
            fetchUbicaciones(),
            fetchMarcas(),
    ])
    }, []);
    return(
        <>
<Box sx={{ mt: 2, mb: 2 }}>
    {/* Mensaje de error */}
    {error && (
        <Typography
            color="error"
            variant="body2"
            sx={{ mt: 1 }}
        >
            {error}
        </Typography>
    )}

    {/* Sección de los filtros */}
    <Box
        sx={{
            display: 'flex',
            flexWrap: 'wrap',
            alignItems: 'center',
            gap: 2,
            p: 2,
        }}
    >
        {/* Estados */}
        <Box sx={{ m: 1, minWidth: 200, flex: '1 1 200px' }}>
            <Dropdown
                label="estado"
                opciones={estados.map(estado => ({
                    id: estado.idEstado,
                    nombre: estado.nombre
                }))}
                value={filtro.idEstado}
                onChange={(value) =>
                    setFiltros({
                        ...filtro,
                        idEstado: value
                    })}
            />
        </Box>

        <Box sx={{ m: 1, minWidth: 200, flex: '1 1 200px' }}>
            <Autocompletar
                label="Tipo"
                opciones={tipos.map(t => ({
                    id: t.idTipo,
                    nombre: t.nombre
                }))}
                value={filtro.idTipo}
                onChange={value => setFiltros({ ...filtro, idTipo: value })}
            />
        </Box>

        <Box sx={{ m: 1, minWidth: 200, flex: '1 1 200px' }}>
            <Autocompletar
                label="Persona"
                opciones={personas.map(p => ({
                    id: p.idPersona,
                    nombre: `${p.nombre} ${p.apellido}`
                }))}
                value={filtro.idPersona}
                onChange={value => setFiltros({ ...filtro, idPersona: value })}
            />
        </Box>

        <Box sx={{ m: 1, minWidth: 200, flex: '1 1 200px' }}>
            <Autocompletar
                label="Ubicación"
                opciones={ubicaciones.map(u => ({
                    id: u.idUbicacion,
                    nombre: u.nombre
                }))}
                value={filtro.idUbicacion}
                onChange={value => setFiltros({ ...filtro, idUbicacion: value })}
            />
        </Box>

        <Box sx={{ m: 1, minWidth: 200, flex: '1 1 200px' }}>
            <Autocompletar
                label="Marca"
                opciones={marcas.map(m => ({
                    id: m.idMarca,
                    nombre: m.nombre
                }))}
                value={filtro.idMarca}
                onChange={value => setFiltros({ ...filtro, idMarca: value })}
            />
        </Box>
    </Box>
</Box>
        </>
    )


}