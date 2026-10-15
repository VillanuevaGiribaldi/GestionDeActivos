Trabajo de Graduación - Gestoón de Activos informáticos
Autores:
- Maximiliano manzur
- Camilo Villanueva Giribaldi
Tutor:
- Carlos Albaaca Paraván

## Guia de uso con docker:
### Iniciar los contenedores: 

    docker compose up --watch

flags opcionales: 
  `-d` para poder cerrar la linea de comandos
  `--build` si se modificó algún dockerfile o compose

Acceder a la linea de comandos de un contenedor:

    doker exec -it activos-api sh

o:

    doker exec -it activos-frontend sh

### Variables de entorno
Api tiene acceso a las variables de entorno en las carpetas:
- .env.database
- .env.node
- /activos-api/.env

activos-frontend tiene acceso a las variablesde entorno en las carpetas:
- .env.node
- /activos-frontend/.env

Si es usada por la api y el frontend -> .env.node
Si es usada por la db y api -> .env.database
Si es usada solo por un servidor -> .env del correspondiente

## Arquitectura del proyecto

El stack se compone de tres servicios orquestados con Docker Compose:

- **`activos-db`**: base de datos MySQL 8.0, con los datos persistidos en el volumen `mysql-data` para que no se pierdan al reiniciar el contenedor.
- **`activos-api`**: API en Node.js + Express, expuesta en el puerto `3000`.
- **`activos-frontend`**: aplicación React + Vite, expuesta en el puerto `5173`.

Ambos servicios de Node (frontend y backend) usan **Docker Compose Watch** (`develop.watch`) para sincronizar cambios de código en caliente durante el desarrollo, excluyendo `node_modules` del sync y reconstruyendo la imagen automáticamente si cambia `package.json`.
