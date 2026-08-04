
WITH RECURSIVE ArbolUbicaciones AS (
    SELECT
        idUbicacion,
        idUbicacionPadre,
        nombre,
        CAST(nombre AS CHAR(200)) AS ruta,
        0 AS nivel
    FROM Ubicaciones
    WHERE idUbicacionPadre IS NULL

    UNION ALL

    SELECT
        u.idUbicacion,
        u.idUbicacionPadre,
        u.nombre,
        CONCAT(a.ruta, ' > ', u.nombre),
        a.nivel + 1
    FROM Ubicaciones u
    JOIN ArbolUbicaciones a
        ON u.idUbicacionPadre = a.idUbicacion
)
SELECT
    REPEAT('   ', nivel) AS indentacion,
    nombre,
    ruta
FROM ArbolUbicaciones;