# Caso 3 - PostgreSQL con Docker, Backups Automáticos y Docker Compose

## Descripción

Este proyecto corresponde al **Caso 3 de la Evaluación del Módulo 2 de DevOps**.

El objetivo es implementar un entorno completamente containerizado utilizando Docker y Docker Compose, donde se despliega una base de datos PostgreSQL inicializada automáticamente mediante un archivo `init.sql`.

Adicionalmente, se implementa un segundo servicio encargado de realizar backups automáticos de la base de datos y eliminar backups antiguos utilizando tareas programadas con Cron.

La solución utiliza:

- Docker
- Dockerfile
- Docker Compose
- PostgreSQL 16
- Docker Networks
- Docker Volumes
- Port Mapping
- Shell Script
- Cron

---

## Arquitectura

La solución está compuesta principalmente por dos servicios:

### Servicio `db`

Contiene PostgreSQL y se encarga de:

- Ejecutar PostgreSQL 16.
- Inicializar automáticamente la base de datos mediante `init.sql`.
- Crear la base de datos `escuela`.
- Crear la tabla `alumnos`.
- Insertar registros iniciales.
- Exponer PostgreSQL mediante el puerto `5432`.
- Mantener los datos mediante un volumen persistente.

### Servicio `backup`

Se encarga de:

- Conectarse al servicio PostgreSQL.
- Ejecutar `pg_dump`.
- Generar backups de la base de datos `escuela`.
- Ejecutar backups cada 2 horas mediante Cron.
- Ejecutar la limpieza cada 4 horas.
- Conservar únicamente el backup más reciente.
- Almacenar los backups en un volumen persistente.

---

## Estructura del proyecto

```text
Caso-3-PostgreSQL
|
|   compose.yaml
|   README.md
|
+---backup
|       backup.sh
|       cleanup.sh
|       crontab
|       Dockerfile
|
\---postgres
        Dockerfile
        init.sql
```

---

## PostgreSQL

La imagen personalizada de PostgreSQL se construye mediante:

```text
postgres/Dockerfile
```

El Dockerfile utiliza PostgreSQL 16 como imagen base y copia `init.sql` al directorio de inicialización de PostgreSQL.

```dockerfile
FROM postgres:16

COPY init.sql /docker-entrypoint-initdb.d/init.sql
```

Cuando PostgreSQL se inicializa por primera vez, ejecuta automáticamente el archivo `init.sql`.

---

## Inicialización de la base de datos

El archivo:

```text
postgres/init.sql
```

es utilizado para crear automáticamente la base de datos:

```text
escuela
```

Dentro de esta base se crea la tabla:

```text
alumnos
```

y se insertan los registros iniciales utilizados para las pruebas.

La información puede verificarse ingresando al contenedor:

```bash
docker exec -it postgres-caso3 psql -U postgres
```

Posteriormente:

```sql
\c escuela
```

Para listar las tablas:

```sql
\dt
```

Y para consultar los registros:

```sql
SELECT * FROM alumnos;
```

---

## Docker Compose

Toda la solución es administrada mediante:

```text
compose.yaml
```
Docker Compose permite levantar los servicios de PostgreSQL y Backup desde una sola configuración.

Para construir y levantar el proyecto:

```bash
docker compose up -d --build
```
Para verificar los servicios:

```bash
docker compose ps
```
---

## Puertos

PostgreSQL utiliza el puerto:

```text
5432
```

El mapeo configurado es:

```text
5432:5432
```

Esto permite acceder al servicio PostgreSQL desde el host mediante el puerto `5432`.

---

## Docker Network

Los servicios se encuentran conectados mediante una red Docker de tipo `bridge`.

La red definida en Docker Compose es:

```text
red_postgres
```

Docker Compose genera el recurso con un nombre similar a:

```text
caso-3-postgresql_red_postgres
```

Esta red permite que el servicio `backup` se comunique con PostgreSQL utilizando el nombre del servicio:

```text
db
```

Por ejemplo:

```bash
pg_dump -h db -U postgres -d escuela
```

Para verificar la red:

```bash
docker network ls --filter "name=caso-3-postgresql"
```

---

## Docker Volumes

Se utilizan dos volúmenes.

### Volumen PostgreSQL

```text
postgres_datos
```

Es utilizado para mantener persistentes los datos de PostgreSQL.

Se monta en:

```text
/var/lib/postgresql/data
```

### Volumen de backups

```text
backups
```

Se utiliza para almacenar los archivos `.sql` generados por el proceso de backup.

Se monta en:

```text
/backups
```

Docker Compose puede mostrarlos con nombres similares a:

```text
caso-3-postgresql_postgres_datos
caso-3-postgresql_backups
```

Para verificarlos:

```bash
docker volume ls --filter "name=caso-3-postgresql"
```

---

## Backup automático

El archivo:

```text
backup/backup.sh
```

realiza el backup de la base de datos PostgreSQL utilizando:

```bash
pg_dump
```

Los archivos generados utilizan la fecha y hora dentro del nombre.

Ejemplo:

```text
escuela_20260815_215323.sql
```

Los backups son almacenados en:

```text
/backups
```

Para ejecutar manualmente el backup:

```bash
docker exec postgres-backup /scripts/backup.sh
```

Para comprobar los archivos generados:

```bash
docker exec postgres-backup ls -lh /backups
```

---

## Limpieza de backups

El script:

```text
backup/cleanup.sh
```

elimina los backups antiguos y conserva únicamente el backup más reciente.

Para probarlo manualmente:

```bash
docker exec postgres-backup /scripts/cleanup.sh
```

Posteriormente se pueden verificar los archivos:

```bash
docker exec postgres-backup ls -lh /backups
```

---

## Cron

Cron se ejecuta dentro del contenedor encargado de los backups.

La configuración final es:

```cron
0 */2 * * * root /scripts/backup.sh
0 */4 * * * root /scripts/cleanup.sh
```

Esto significa:

| Tarea | Frecuencia |
|---|---|
| Backup PostgreSQL | Cada 2 horas |
| Limpieza de backups | Cada 4 horas |

La primera tarea ejecuta:

```text
/scripts/backup.sh
```

cada 2 horas.

La segunda ejecuta:

```text
/scripts/cleanup.sh
```

cada 4 horas.

Para verificar la configuración dentro del contenedor:

```bash
docker exec postgres-backup cat /etc/cron.d/postgres-backup
```

Para comprobar que Cron está ejecutándose:

```bash
docker exec postgres-backup ps aux
```

Debe aparecer un proceso similar a:

```text
cron -f
```

---

## Construcción y ejecución

Para levantar completamente el proyecto:

```bash
docker compose up -d --build
```

Verificar los contenedores:

```bash
docker compose ps
```

Verificar los volúmenes:

```bash
docker volume ls --filter "name=caso-3-postgresql"
```

Verificar la red:

```bash
docker network ls --filter "name=caso-3-postgresql"
```

---

## Detener el proyecto

Para detener y eliminar los contenedores y la red creada por Docker Compose:

```bash
docker compose down
```

Los volúmenes no son eliminados mediante este comando, permitiendo conservar los datos.

Para eliminar también los volúmenes se utilizaría:

```bash
docker compose down -v
```

> **Advertencia:** `-v` elimina los volúmenes asociados y, por lo tanto, puede eliminar los datos persistentes de PostgreSQL y los backups.
