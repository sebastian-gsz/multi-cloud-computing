# Sistema de gestión de vuelos (Oracle APEX)

Este repositorio contiene el modelo de datos y la estructura lógica para una aplicación de gestión de aeropuertos, vuelos y reservas de billetes, desarrollada sobre la plataforma **Oracle APEX**.

## Modelo de datos

La base de datos está diseñada sobre **Oracle Database 11g** (o superior) y consta de 6 entidades principales que gestionan la logística aeronáutica.

### Entidades principales:

* **`clienti`**: Almacena la información personal y de contacto de los pasajeros.
* **`zbor` (Vuelos)**: La tabla central que conecta aeropuertos de origen/destino, compañías aéreas y precios.
* **`bilet` (Billetes)**: Gestiona la relación entre un cliente y un vuelo específico.
* **`aeroport` & `oras**`: Jerarquía geográfica para ubicar los aeropuertos en sus respectivas ciudades y países.
* **`companie`**: Catálogo de aerolíneas que operan los vuelos.

---

## Requisitos e instalación

Para implementar este esquema en tu instancia de Oracle APEX:

1. Accede a tu **Workspace** de Oracle APEX.
2. Ve a **SQL Workshop > SQL Scripts**.
3. Haz clic en **Upload** y sube el archivo `sript.sql` incluido en este repo.
4. Selecciona el script y pulsa **Run**.
5. (Opcional) Una vez creadas las tablas, puedes usar el **App Builder** para generar la aplicación automáticamente usando el asistente "App from Spreadsheet/Script".

---

## Estructura del script SQL

El script incluye:

* **DDL de tablas**: Creación de las 6 tablas con tipos de datos optimizados.
* **Restricciones de integridad**:
* `PRIMARY KEY` para todas las tablas.
* `FOREIGN KEY` para asegurar, por ejemplo, que no existan vuelos a aeropuertos inexistentes o billetes sin clientes asociados.


* **Relaciones especiales**: La tabla `zbor` posee una doble relación con `aeroport` para definir tanto el origen como el destino.

---

## Funcionalidades de la aplicación (Sugeridas)

Basado en este modelo, la aplicación APEX permite:

1. **Dashboard de vuelos**: Visualización de salidas y llegadas en tiempo real.
2. **Gestión de clientes**: CRUD completo para la administración de pasajeros.
3. **Reserva de billetes**: Proceso de venta vinculando vuelos disponibles con clientes registrados.
4. **Reportes geográficos**: Análisis de tráfico por ciudad (`oras`) y país.

---

## Notas de versión

* **Generado con**: Oracle SQL Developer Data Modeler 23.1.
* **Compatibilidad**: Testeado en Oracle Database 11g y Oracle Autonomous Database (Cloud).

---

*Proyecto creado para la gestión académica/profesional de transporte aéreo.*