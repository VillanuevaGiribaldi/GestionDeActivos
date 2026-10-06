Trabajo de Graduación - Gestoón de Activos informáticos
Autores:
- Maximiliano manzur
- Camilo Villanueva Giribaldi
Tutor:
- Carlos Albaaca Paraván

El repositorio contiene una carpeta con las queries SQL para creación de base de datos y otro que incluye un docker compose para ejecutar todo el stack simultaneamente.
Para iniciar los contenedores ejecuta el sgte comando desde adentro de docker-test:

  `docker compose up --watch`

Agregar la flag `--build` si se modifico compose o algún dockerfile desde la última vez que se usó

Una vez iniciado el compose puedes revisar el estado de los contenedores en la aplicación o con el comando `docker ps`.
Deberías tener uno llamado `docker-test-activos-backend-1` o similar.
Puede usar el sgte comando para acceder al terminal del backend (node):
 `docker exec -it docker-test-activos-backend-1 sh`
Allí puedes ejecutar cualquier comando que necesite node (`npm run`, `npm install`,etc.)
