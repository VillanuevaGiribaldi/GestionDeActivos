Trabajo de Graduación - Gestoón de Activos informáticos
Autores:
- Maximiliano manzur
- Camilo Villanueva Giribaldi
Tutor:
- Carlos Albaaca Paraván

El repositorio contiene una carpeta con las queries SQL para creación de base de datos y otro que incluye un docker compose para ejecutar todo el stack simultaneamente.
Para iniciar los contenedores ejecuta el sgte comando desde adentro de docker-test:

  `docker compose up --watch`
Con esto inicia el servidor mysql, node y vite (react). actualmente node no ejecuta nada por que no tenemos código. Frontend tiene un template de vite.

Agregar la flag `--build` si se modifico compose o algún dockerfile desde la última vez que se usó

Una vez iniciado el compose puedes revisar el estado de los contenedores en la aplicación o con el comando `docker ps`.
Deberías tener uno llamado `docker-test-activos-backend-1` o similar.
Puede usar el sgte comando para acceder al terminal del backend (node):
 `docker exec -it docker-test-activos-backend-1 sh`
Allí puedes ejecutar cualquier comando que necesite node (`npm run`, `npm install`,etc.)
Con este comando se accede al contenedor del front end:
`docker exec -it docker-test-activos-frontend-1 sh`


## Arquitectura del proyecto

El stack se compone de tres servicios orquestados con Docker Compose:

- **`activos-db`**: base de datos MySQL 8.0, con los datos persistidos en el volumen `mysql-data` para que no se pierdan al reiniciar el contenedor.
- **`activos-backend`**: API en Node.js + Express, expuesta en el puerto `3000`.
- **`activos-frontend`**: aplicación React + Vite, expuesta en el puerto `5173`.

Ambos servicios de Node (frontend y backend) usan **Docker Compose Watch** (`develop.watch`) para sincronizar cambios de código en caliente durante el desarrollo, excluyendo `node_modules` del sync y reconstruyendo la imagen automáticamente si cambia `package.json`.
