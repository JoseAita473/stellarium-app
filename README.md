# Stellarium Observatorio y Planetario - Aplicativo de gestión de reservas

Aplicativo de escritorio (Python + tkinter) que consume la base de datos `stellarium_db` (MySQL 8.0)
mediante procedimientos almacenados. Sin frameworks ni ORM. Entrega 05.

## Funcionalidades
- **Clientes:** insertar, modificar y dar de baja (borrado lógico).
- **Reservas:** insertar, modificar, reprogramar y eliminar (borrado lógico), con lista de turnos disponibles y control de capacidad.
- **Reportes:** 10 consultas (8 con JOIN) ejecutadas mediante procedimientos almacenados.
- **Triggers:** validan la reprogramación, la correspondencia grupo ↔ turno y las bajas de clientes con reservas activas.

## Estructura del repositorio
```
app_stellarium.py        Código fuente del aplicativo (documentado)
logo_stellarium.png      Logo mostrado en el encabezado
config.ejemplo.json      Plantilla de configuración de la conexión
requirements.txt         Dependencias de Python
db/
  stellarium_completo.sql            Script completo (tablas + datos + procedimientos + triggers + datos ampliados)
  stellarium_procedimientos.sql      Solo borrado lógico, triggers y procedimientos
  stellarium_parche_turnos.sql       Parche: capacidad de espacios y lista de turnos (no borra datos)
  stellarium_datos_ampliados.sql     Solo los datos de prueba adicionales
```

## Cómo ejecutarlo
1. **Base de datos:** en MySQL Workbench, abrir `db/stellarium_completo.sql` y ejecutarlo completo.
2. **Dependencias:** `pip install mysql-connector-python`
3. **Configuración:** copiar `config.ejemplo.json` como `config.json` y escribir la contraseña de MySQL.
4. **Ejecutar:** `python app_stellarium.py`

## Generar el ejecutable (Windows)
```
pip install pyinstaller
pyinstaller --onefile --windowed --name Stellarium --add-data "logo_stellarium.png;." app_stellarium.py
```
El archivo queda en `dist/Stellarium.exe`. Debe acompañarse de un `config.json` en la misma carpeta.

## Herramientas
MySQL Server 8.0 · MySQL Workbench 8.0 CE · Python 3 · tkinter · mysql-connector-python · PyInstaller
