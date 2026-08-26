-- ===========================================  BUSCAR ATRIBUTOS AVANZADO
DROP PROCEDURE IF EXISTS sp_buscarActivosAvanzado;
DELIMITER //

CREATE PROCEDURE sp_buscarActivosAvanzado(
    -- 1. Búsqueda global de texto (Nombre, Modelo, Serie y Catálogos)
    IN pFiltroTexto VARCHAR(100), 
    
    -- 2. Filtros exactos por catálogos (Opcionales, envían IDs)
    IN pIdTipo INT,
    IN pIdMarca INT,
    IN pIdUbicacion INT,
    IN pIdEstado INT,
    IN pIdPersona INT,
    
    -- 3. Filtros avanzados para atributos dinámicos (JSON)
    IN pAtributoClave VARCHAR(45),
    IN pAtributoValor VARCHAR(100),
    
    -- 4. Ordenamiento Dinámico
    IN pOrdenColumna VARCHAR(45),
    IN pOrdenDireccion VARCHAR(4), -- 'ASC' o 'DESC'
    
    -- 5. Paginación
    IN pLimit INT,
    IN pOffset INT
)
BEGIN
    -- =========================================================================
    -- 1. SANITIZACIÓN CRÍTICA (Frontend a BD)
    -- =========================================================================
    -- Convertimos strings vacíos enviados por la web a NULL reales
    IF TRIM(pFiltroTexto) = '' THEN SET pFiltroTexto = NULL; END IF;
    IF TRIM(pAtributoClave) = '' THEN SET pAtributoClave = NULL; END IF;
    IF TRIM(pAtributoValor) = '' THEN SET pAtributoValor = NULL; END IF;
    IF TRIM(pOrdenColumna) = '' THEN SET pOrdenColumna = NULL; END IF;
    IF TRIM(pOrdenDireccion) = '' THEN SET pOrdenDireccion = NULL; END IF;

    -- =========================================================================
    -- 2. CONFIGURACIÓN DE SEGURIDAD Y VALORES POR DEFECTO
    -- =========================================================================
    IF pLimit IS NULL OR pLimit <= 0 THEN SET pLimit = 50; END IF;
    IF pOffset IS NULL OR pOffset < 0 THEN SET pOffset = 0; END IF;
    IF pOrdenColumna IS NULL THEN SET pOrdenColumna = 'fechaRegistro'; END IF;
    IF pOrdenDireccion IS NULL THEN SET pOrdenDireccion = 'DESC'; END IF;

    -- =========================================================================
    -- 3. CONSULTA PRINCIPAL
    -- =========================================================================
    SELECT 
        a.idActivo,
        a.nombre AS nombreActivo,
        a.numeroSerie,
        a.modelo,
        a.precioUnitario,
        a.fechaRegistro,
        
        -- Nombres legibles de los catálogos para el frontend
        t.nombre AS tipo,
        m.nombre AS marca,
        u.nombre AS ubicacion,
        e.nombre AS estado,
        CONCAT(p.nombre, ' ', p.apellido) AS personaAsignada,
        
        -- JSON completo de características extra
        a.atributosExtra,
        
        -- Función de Ventana para el Total de Registros (Paginación Frontend)
        COUNT(*) OVER() AS totalRegistrosTotales
        
    FROM Activos a
    -- INNER JOIN para los catálogos obligatorios
    INNER JOIN Tipos t ON a.idTipo = t.idTipo
    INNER JOIN Marcas m ON a.idMarca = m.idMarca
    INNER JOIN Ubicaciones u ON a.idUbicacion = u.idUbicacion
    INNER JOIN Estados e ON a.idEstado = e.idEstado
    -- LEFT JOIN para el catálogo opcional
    LEFT JOIN Personas p ON a.idPersona = p.idPersona
    
    WHERE 
        -- A) BÚSQUEDA GLOBAL HÍBRIDA (Busca texto en Activos Y Catálogos)
        (pFiltroTexto IS NULL OR 
         a.nombre LIKE CONCAT('%', pFiltroTexto, '%') OR 
         a.numeroSerie LIKE CONCAT('%', pFiltroTexto, '%') OR 
         a.modelo LIKE CONCAT('%', pFiltroTexto, '%') OR
         t.nombre LIKE CONCAT('%', pFiltroTexto, '%') OR 
         m.nombre LIKE CONCAT('%', pFiltroTexto, '%') OR 
         u.nombre LIKE CONCAT('%', pFiltroTexto, '%') OR 
         e.nombre LIKE CONCAT('%', pFiltroTexto, '%')
        )
        
        -- B) FILTROS EXACTOS POR ID (Dropdowns)
        AND (pIdTipo IS NULL OR a.idTipo = pIdTipo)
        AND (pIdMarca IS NULL OR a.idMarca = pIdMarca)
        AND (pIdUbicacion IS NULL OR a.idUbicacion = pIdUbicacion)
        AND (pIdEstado IS NULL OR a.idEstado = pIdEstado)
        AND (pIdPersona IS NULL OR a.idPersona = pIdPersona)
        
        -- C) FILTRO PROFUNDO EN JSON (Case-insensitive)
        AND (pAtributoClave IS NULL OR pAtributoValor IS NULL OR 
             LOWER(JSON_UNQUOTE(JSON_EXTRACT(a.atributosExtra, CONCAT('$."', pAtributoClave, '"')))) LIKE CONCAT('%', LOWER(pAtributoValor), '%')
        )
        
    -- =========================================================================
    -- 4. ORDENAMIENTO DINÁMICO SEGURO (Anti-Inyección SQL)
    -- =========================================================================
    ORDER BY 
        CASE WHEN pOrdenDireccion = 'ASC' THEN
            CASE pOrdenColumna
                WHEN 'nombreActivo' THEN a.nombre
                WHEN 'numeroSerie' THEN a.numeroSerie
                WHEN 'marca' THEN m.nombre
                WHEN 'tipo' THEN t.nombre
                WHEN 'estado' THEN e.nombre
                WHEN 'ubicacion' THEN u.nombre
                ELSE a.fechaRegistro
            END
        END ASC,
        CASE WHEN pOrdenDireccion = 'DESC' THEN
            CASE pOrdenColumna
                WHEN 'nombreActivo' THEN a.nombre
                WHEN 'numeroSerie' THEN a.numeroSerie
                WHEN 'marca' THEN m.nombre
                WHEN 'tipo' THEN t.nombre
                WHEN 'estado' THEN e.nombre
                WHEN 'ubicacion' THEN u.nombre
                ELSE a.fechaRegistro
            END
        END DESC
        
    -- =========================================================================
    -- 5. PAGINACIÓN
    -- =========================================================================
    LIMIT pLimit OFFSET pOffset;

END//
DELIMITER ;

-- ===========================================  VER HISTORIAL
DROP PROCEDURE IF EXISTS sp_verHistorialActivo;
DELIMITER //

CREATE PROCEDURE sp_verHistorialActivo(
    IN pIdActivo INT
)
BEGIN
    -- 1. Validación temprana
    IF pIdActivo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el ID del activo para consultar su historial';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Activos WHERE idActivo = pIdActivo) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El activo indicado no existe en el sistema';
    END IF;

    -- 2. Consulta de lectura (Timeline)
    SELECT 
        h.idHistorial,
        h.fecha,
        u.username AS usuario,
        CONCAT(p.nombre, ' ', p.apellido) AS responsable,
        
        -- Traducción de los códigos de auditoría para el Frontend
        CASE h.tipo
            WHEN 'A' THEN 'Alta de Activo'
            WHEN 'M' THEN 'Modificación'
            WHEN 'B' THEN 'Baja'
            WHEN 'R' THEN 'Envío a Reparación'
            WHEN 'D' THEN 'Devolución de Reparación'
            ELSE 'Otro'
        END AS accionRealizada,
        
        h.comentario,
        
        -- Los JSON se devuelven crudos para que el Frontend dibuje un "Antes vs Después"
        h.estadoAnterior,
        h.estadoNuevo
        
    FROM Historial h
    INNER JOIN Usuarios u ON h.idUsuario = u.idUsuario
    INNER JOIN Personas p ON u.idPersona = p.idPersona
    WHERE h.idActivo = pIdActivo
    ORDER BY h.fecha DESC;

END//
DELIMITER ;

-- =========================================================
-- PRUEBAS DEL PROCEDIMIENTO DE HISTORIAL
-- =========================================================
CALL sp_verHistorialActivo(1);
