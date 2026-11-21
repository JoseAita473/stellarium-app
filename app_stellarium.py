"""
Aplicativo Stellarium Observatorio y Planetario - Entrega 05
Cliente de escritorio (tkinter) que consume la base de datos stellarium_db.

- Sin frameworks ni ORM: solo mysql-connector y llamadas a procedimientos almacenados.
- Modulos: Clientes (CRUD), Reservas (CRUD + reprogramar) y Reportes (10 consultas).
- Requisito: pip install mysql-connector-python
- Configuracion: copiar config.ejemplo.json como config.json y escribir la clave de MySQL.
"""
import json
import os
import sys
import tkinter as tk
from tkinter import ttk, messagebox

import mysql.connector
from mysql.connector import Error

# --- Configuracion de conexion -------------------------------------------
# Los datos de conexion se leen del archivo config.json, que debe estar junto
# al aplicativo (copiar config.ejemplo.json como config.json y poner la clave).
# Asi la contrasena no se escribe en el codigo ni se sube a GitHub.
CONFIG = {
    "host": "localhost",
    "port": 3306,
    "user": "root",
    "password": "",
    "database": "stellarium_db",
}


def cargar_configuracion():
    """Actualiza CONFIG con los valores de config.json, si el archivo existe."""
    carpeta = os.path.dirname(sys.executable if getattr(sys, "frozen", False)
                              else os.path.abspath(__file__))
    ruta = os.path.join(carpeta, "config.json")
    if os.path.exists(ruta):
        with open(ruta, encoding="utf-8") as archivo:
            CONFIG.update(json.load(archivo))
    return ruta


RUTA_CONFIG = cargar_configuracion()

# Listas de valores permitidos (deben coincidir con los CHECK de la BD)
TIPOS_DOC = ["DNI Peruano", "Pasaporte", "Carné de Extranjería"]
CANALES = ["Oficina", "WhatsApp", "Viator", "Airbnb", "Cuponidad"]
MEDIOS_PAGO = ["", "Yape", "Transferencia", "Tarjeta", "Efectivo"]
ESTADOS_PAGO = ["Pendiente", "Pagado"]

# Reportes: (nombre visible, procedimiento, requiere fecha)
REPORTES = [
    ("1. Reservas con datos del cliente", "sp_rpt_reservas_clientes", False),
    ("2. Reservas de una fecha (AAAA-MM-DD)", "sp_rpt_reservas_por_fecha", True),
    ("3. Reservas pendientes de pago", "sp_rpt_pendientes_pago", False),
    ("4. Reservas y visitantes por canal", "sp_rpt_reservas_por_canal", False),
    ("5. Ingresos por medio de pago", "sp_rpt_ingresos_medio_pago", False),
    ("6. Servicios mas solicitados", "sp_rpt_servicios_solicitados", False),
    ("7. Clientes con mas de una reserva", "sp_rpt_clientes_recurrentes", False),
    ("8. Reservas reprogramadas", "sp_rpt_reprogramadas", False),
    ("9. Grupos y guias asignados", "sp_rpt_grupos_guias", False),
    ("10. Ocupacion de espacios por turno", "sp_rpt_ocupacion_turnos", False),
]


# --- Diseño visual (paleta tomada del logo de Stellarium) ---------------
AZUL_NOCHE = "#0A0B3D"   # azul oscuro del logo
TURQUESA = "#3B8EA9"     # azul turquesa del logo
FONDO = "#F5F7FA"
BLANCO = "#FFFFFF"
TEXTO = "#1C2040"
TENUE = "#7A8199"
BORDE = "#DDE2EB"
FILA_ALTERNA = "#F1F4F9"
PELIGRO = "#A63D40"
FUENTE = "Segoe UI"


def ruta_recurso(nombre):
    """Ruta de un archivo junto al script (o dentro del ejecutable de PyInstaller)."""
    base = getattr(sys, "_MEIPASS", os.path.dirname(os.path.abspath(__file__)))
    return os.path.join(base, nombre)


def aplicar_estilo(raiz):
    """Configura un tema minimalista y moderno para todos los widgets ttk."""
    raiz.configure(bg=FONDO)
    estilo = ttk.Style(raiz)
    estilo.theme_use("clam")
    estilo.configure(".", font=(FUENTE, 10), background=FONDO, foreground=TEXTO)
    estilo.configure("TFrame", background=FONDO)
    estilo.configure("TLabel", background=FONDO, foreground=TEXTO)
    estilo.configure("Hint.TLabel", foreground=TENUE, font=(FUENTE, 9))
    estilo.configure("TCheckbutton", background=FONDO, foreground=TEXTO)
    estilo.map("TCheckbutton", background=[("active", FONDO)])
    estilo.configure("TLabelframe", background=FONDO, bordercolor=BORDE, relief="solid", borderwidth=1)
    estilo.configure("TLabelframe.Label", background=FONDO, foreground=AZUL_NOCHE, font=(FUENTE, 10, "bold"))

    # Campos de texto y listas desplegables
    estilo.configure("TEntry", fieldbackground=BLANCO, bordercolor=BORDE, lightcolor=BORDE,
                     darkcolor=BORDE, padding=5)
    estilo.map("TEntry", bordercolor=[("focus", TURQUESA)], lightcolor=[("focus", TURQUESA)])
    estilo.configure("TCombobox", fieldbackground=BLANCO, background=BLANCO, bordercolor=BORDE,
                     lightcolor=BORDE, darkcolor=BORDE, arrowcolor=AZUL_NOCHE, padding=5)
    estilo.map("TCombobox", fieldbackground=[("readonly", BLANCO)], bordercolor=[("focus", TURQUESA)])
    raiz.option_add("*TCombobox*Listbox.background", BLANCO)
    raiz.option_add("*TCombobox*Listbox.selectBackground", TURQUESA)
    raiz.option_add("*TCombobox*Listbox.font", (FUENTE, 10))

    # Botones: principal (azul), secundario (borde) y de peligro
    estilo.configure("TButton", background=AZUL_NOCHE, foreground=BLANCO, borderwidth=0,
                     padding=(16, 7), font=(FUENTE, 10, "bold"), focusthickness=0)
    estilo.map("TButton", background=[("active", TURQUESA), ("pressed", TURQUESA)])
    estilo.configure("Ghost.TButton", background=BLANCO, foreground=AZUL_NOCHE, borderwidth=1,
                     bordercolor=BORDE)
    estilo.map("Ghost.TButton", background=[("active", FILA_ALTERNA)])
    estilo.configure("Danger.TButton", background=BLANCO, foreground=PELIGRO, borderwidth=1,
                     bordercolor=BORDE)
    estilo.map("Danger.TButton", background=[("active", "#F8E9E9")])

    # Pestañas
    estilo.configure("TNotebook", background=FONDO, borderwidth=0, tabmargins=(0, 0, 0, 0))
    estilo.configure("TNotebook.Tab", background=FONDO, foreground=TENUE, padding=(22, 10),
                     font=(FUENTE, 10), borderwidth=0)
    estilo.map("TNotebook.Tab", background=[("selected", BLANCO)], foreground=[("selected", AZUL_NOCHE)],
               font=[("selected", (FUENTE, 10, "bold"))])

    # Tablas
    estilo.configure("Treeview", background=BLANCO, fieldbackground=BLANCO, foreground=TEXTO,
                     rowheight=28, borderwidth=0, font=(FUENTE, 10))
    estilo.configure("Treeview.Heading", background=AZUL_NOCHE, foreground=BLANCO, relief="flat",
                     font=(FUENTE, 10, "bold"), padding=(8, 7))
    estilo.map("Treeview.Heading", background=[("active", AZUL_NOCHE)])
    estilo.map("Treeview", background=[("selected", TURQUESA)], foreground=[("selected", BLANCO)])
    estilo.configure("Vertical.TScrollbar", background=BORDE, troughcolor=FONDO, borderwidth=0, arrowsize=12)
    estilo.configure("Horizontal.TScrollbar", background=BORDE, troughcolor=FONDO, borderwidth=0, arrowsize=12)


# --- Acceso a datos ----------------------------------------------------
def llamar(procedimiento, args=()):
    """Ejecuta un procedimiento almacenado y devuelve (columnas, filas)."""
    conexion = mysql.connector.connect(**CONFIG)
    try:
        cursor = conexion.cursor()
        cursor.callproc(procedimiento, list(args))
        columnas, filas = [], []
        for resultado in cursor.stored_results():
            columnas = list(resultado.column_names)
            filas = resultado.fetchall()
        conexion.commit()
        return columnas, filas
    finally:
        conexion.close()


def texto(valor):
    """Convierte un valor de la BD a texto para mostrarlo (None -> vacio)."""
    return "" if valor is None else str(valor)


def nulo(cadena):
    """Cadena vacia -> None (NULL en la BD)."""
    cadena = cadena.strip()
    return cadena if cadena else None


def ejecutar(accion):
    """Ejecuta una accion mostrando los errores de MySQL (incluye los de los triggers)."""
    try:
        return accion()
    except Error as e:
        detalle = getattr(e, "msg", str(e))
        if not os.path.exists(RUTA_CONFIG):
            detalle += f"\n\nNo se encontro el archivo de configuracion:\n{RUTA_CONFIG}"
        messagebox.showerror("Error de base de datos", detalle)
    except ValueError:
        messagebox.showerror("Dato invalido", "Revise los campos numericos (cantidad y monto).")
    return None


# --- Componentes de interfaz -------------------------------------------
class Tabla(ttk.Frame):
    """Treeview con barras de desplazamiento que se adapta a las columnas recibidas."""

    def __init__(self, padre, al_seleccionar=None, altura=10, anchos=None):
        super().__init__(padre)
        self.filas = {}
        self.anchos = anchos or {}
        self.arbol = ttk.Treeview(self, show="headings", height=altura)
        vert = ttk.Scrollbar(self, orient="vertical", command=self.arbol.yview)
        horiz = ttk.Scrollbar(self, orient="horizontal", command=self.arbol.xview)
        self.arbol.configure(yscrollcommand=vert.set, xscrollcommand=horiz.set)
        self.arbol.tag_configure("alterna", background=FILA_ALTERNA)
        self.arbol.grid(row=0, column=0, sticky="nsew")
        vert.grid(row=0, column=1, sticky="ns")
        horiz.grid(row=1, column=0, sticky="ew")
        self.columnconfigure(0, weight=1)
        self.rowconfigure(0, weight=1)
        if al_seleccionar:
            self.arbol.bind("<<TreeviewSelect>>", lambda _e: al_seleccionar(self.seleccion()))

    def cargar(self, columnas, filas):
        self.arbol.delete(*self.arbol.get_children())
        self.filas = {}
        self.arbol["columns"] = columnas
        for c in columnas:
            self.arbol.heading(c, text=c.replace("_", " ").capitalize())
            self.arbol.column(c, width=self.anchos.get(c, 120), anchor="w")
        for n, fila in enumerate(filas):
            valores = [texto(v) for v in fila]
            iid = self.arbol.insert("", "end", values=valores, tags=("alterna",) if n % 2 else ())
            self.filas[iid] = dict(zip(columnas, valores))

    def seleccion(self):
        elegido = self.arbol.selection()
        return self.filas.get(elegido[0]) if elegido else None


def crear_formulario(padre, campos):
    """campos: lista de (clave, etiqueta, valores). Devuelve (variables, widgets)."""
    variables, widgets = {}, {}
    for i, (clave, etiqueta, valores) in enumerate(campos):
        fila, col = divmod(i, 2)
        ttk.Label(padre, text=etiqueta).grid(row=fila, column=col * 2, sticky="e", padx=4, pady=3)
        variables[clave] = tk.StringVar()
        if valores is None:
            widget = ttk.Entry(padre, textvariable=variables[clave], width=28)
        else:
            widget = ttk.Combobox(padre, textvariable=variables[clave], values=valores,
                                  state="readonly", width=26)
        widget.grid(row=fila, column=col * 2 + 1, sticky="w", padx=4, pady=3)
        widgets[clave] = widget
    return variables, widgets


def crear_botones(padre, botones):
    barra = ttk.Frame(padre)
    for etiqueta, comando in botones:
        estilo = {"Limpiar": "Ghost.TButton", "Eliminar": "Danger.TButton"}.get(etiqueta, "TButton")
        ttk.Button(barra, text=etiqueta, command=comando, style=estilo).pack(side="left", padx=4)
    return barra


# --- Modulo de clientes ------------------------------------------------
class ModuloClientes(ttk.Frame):
    def __init__(self, padre):
        super().__init__(padre, padding=16)
        marco = ttk.LabelFrame(self, text="Datos del cliente", padding=6)
        marco.pack(fill="x")
        self.v, _ = crear_formulario(marco, [
            ("numero_documento_identidad", "N° documento", None),
            ("tipo_documento", "Tipo de documento", TIPOS_DOC),
            ("nombre", "Nombres", None),
            ("apellido_paterno", "Apellido paterno", None),
            ("apellido_materno", "Apellido materno", None),
        ])
        crear_botones(self, [("Insertar", self.insertar), ("Modificar", self.modificar),
                             ("Eliminar", self.eliminar), ("Limpiar", self.limpiar)]).pack(pady=6)
        self.tabla = Tabla(self, al_seleccionar=self.rellenar)
        self.tabla.pack(fill="both", expand=True)
        self.refrescar()

    def datos(self):
        v = self.v
        return (v["numero_documento_identidad"].get().strip(), v["tipo_documento"].get(),
                v["nombre"].get().strip(), nulo(v["apellido_paterno"].get()),
                nulo(v["apellido_materno"].get()))

    def rellenar(self, fila):
        if fila:
            for clave, var in self.v.items():
                var.set(fila.get(clave, ""))

    def limpiar(self):
        for var in self.v.values():
            var.set("")

    def refrescar(self):
        resultado = ejecutar(lambda: llamar("sp_cliente_listar"))
        if resultado:
            self.tabla.cargar(*resultado)

    def _accion(self, procedimiento, args, mensaje):
        if ejecutar(lambda: llamar(procedimiento, args)) is not None:
            messagebox.showinfo("Cliente", mensaje)
            self.limpiar()
            self.refrescar()

    def insertar(self):
        self._accion("sp_cliente_insertar", self.datos(), "Cliente registrado.")

    def modificar(self):
        self._accion("sp_cliente_modificar", self.datos(), "Cliente actualizado.")

    def eliminar(self):
        doc = self.v["numero_documento_identidad"].get().strip()
        if doc and messagebox.askyesno("Confirmar", f"¿Dar de baja al cliente {doc}?"):
            self._accion("sp_cliente_eliminar", (doc,), "Cliente dado de baja.")


# --- Modulo de reservas ------------------------------------------------
class ModuloReservas(ttk.Frame):
    def __init__(self, padre):
        super().__init__(padre, padding=16)
        superior = ttk.Frame(self)
        superior.pack(fill="x")
        marco = ttk.LabelFrame(superior, text="Datos de la reserva", padding=6)
        marco.pack(side="left", fill="y")
        self.v, self.w = crear_formulario(marco, [
            ("numero_reserva", "N° reserva", None),
            ("documento", "Documento del cliente", None),
            ("servicio_programado", "Servicio", []),
            ("fecha_programada", "Fecha (AAAA-MM-DD)", None),
            ("horario_programado", "Horario (HH:MM)", None),
            ("cantidad_personas", "Cantidad de personas", None),
            ("canal_origen", "Canal de origen", CANALES),
            ("medio_pago", "Medio de pago", MEDIOS_PAGO),
            ("estado_pago", "Estado del pago", ESTADOS_PAGO),
            ("monto_pagado", "Monto pagado (S/)", None),
        ])
        # Lista de turnos existentes con sus espacios disponibles
        panel = ttk.LabelFrame(superior, text="Turnos disponibles", padding=6)
        panel.pack(side="left", fill="both", expand=True, padx=(12, 0))
        self.tabla_turnos = Tabla(panel, al_seleccionar=self.elegir_turno, altura=6,
                                  anchos={"servicio": 150, "fecha": 90, "horario": 80, "disponibles": 90})
        self.tabla_turnos.pack(fill="both", expand=True)
        pie = ttk.Frame(panel)
        pie.pack(fill="x", pady=(6, 0))
        self.solo_futuros = tk.BooleanVar(value=False)
        ttk.Checkbutton(pie, text="Solo turnos desde hoy", variable=self.solo_futuros,
                        command=self.cargar_turnos).pack(side="left")
        ttk.Label(pie, text="Clic en un turno para completar el formulario",
                  style="Hint.TLabel").pack(side="right")
        ttk.Label(self, text="Reprogramar usa el servicio, la fecha y el horario del formulario como nuevo turno.",
                  style="Hint.TLabel").pack(anchor="w", pady=(4, 0))
        crear_botones(self, [("Insertar", self.insertar), ("Modificar", self.modificar),
                             ("Reprogramar", self.reprogramar), ("Eliminar", self.eliminar),
                             ("Limpiar", self.limpiar)]).pack(pady=6)
        self.tabla = Tabla(self, al_seleccionar=self.rellenar)
        self.tabla.pack(fill="both", expand=True)
        self.cargar_servicios()
        self.cargar_turnos()
        self.refrescar()

    def cargar_turnos(self):
        """Muestra los turnos existentes y cuantos espacios quedan en cada uno."""
        resultado = ejecutar(lambda: llamar("sp_turno_listar", (1 if self.solo_futuros.get() else 0,)))
        if resultado:
            self.tabla_turnos.cargar(*resultado)

    def elegir_turno(self, fila):
        """Al elegir un turno de la lista se completan servicio, fecha y horario."""
        if fila:
            self.v["servicio_programado"].set(fila["servicio"])
            self.v["fecha_programada"].set(fila["fecha"])
            self.v["horario_programado"].set(fila["horario"])

    def cargar_servicios(self):
        resultado = ejecutar(lambda: llamar("sp_servicio_listar"))
        if resultado:
            self.w["servicio_programado"]["values"] = [f[0] for f in resultado[1]]

    def rellenar(self, fila):
        if fila:
            for clave, var in self.v.items():
                var.set(fila.get(clave, ""))

    def limpiar(self):
        for var in self.v.values():
            var.set("")

    def refrescar(self):
        resultado = ejecutar(lambda: llamar("sp_reserva_listar"))
        if resultado:
            self.tabla.cargar(*resultado)

    def _accion(self, procedimiento, obtener_args, mensaje):
        def paso():
            return llamar(procedimiento, obtener_args())
        if ejecutar(paso) is not None:
            messagebox.showinfo("Reserva", mensaje)
            self.limpiar()
            self.refrescar()
            self.cargar_turnos()

    def _monto(self):
        monto = nulo(self.v["monto_pagado"].get())
        return float(monto) if monto else None

    def insertar(self):
        v = self.v
        self._accion("sp_reserva_insertar", lambda: (
            v["numero_reserva"].get().strip(), v["documento"].get().strip(),
            v["servicio_programado"].get(), v["fecha_programada"].get().strip(),
            v["horario_programado"].get().strip(), int(v["cantidad_personas"].get()),
            v["canal_origen"].get(), nulo(v["medio_pago"].get()),
            v["estado_pago"].get(), self._monto()), "Reserva registrada.")

    def modificar(self):
        v = self.v
        self._accion("sp_reserva_modificar", lambda: (
            v["numero_reserva"].get().strip(), int(v["cantidad_personas"].get()),
            v["canal_origen"].get(), nulo(v["medio_pago"].get()),
            v["estado_pago"].get(), self._monto()), "Reserva actualizada.")

    def reprogramar(self):
        v = self.v
        self._accion("sp_reserva_reprogramar", lambda: (
            v["numero_reserva"].get().strip(), v["servicio_programado"].get(),
            v["fecha_programada"].get().strip(), v["horario_programado"].get().strip()),
            "Reserva reprogramada.")

    def eliminar(self):
        num = self.v["numero_reserva"].get().strip()
        if num and messagebox.askyesno("Confirmar", f"¿Eliminar la reserva {num}?"):
            self._accion("sp_reserva_eliminar", lambda: (num,), "Reserva eliminada.")


# --- Modulo de reportes ------------------------------------------------
class ModuloReportes(ttk.Frame):
    def __init__(self, padre):
        super().__init__(padre, padding=16)
        barra = ttk.Frame(self)
        barra.pack(fill="x")
        ttk.Label(barra, text="Reporte:").pack(side="left", padx=4)
        self.reporte = tk.StringVar(value=REPORTES[0][0])
        ttk.Combobox(barra, textvariable=self.reporte, values=[r[0] for r in REPORTES],
                     state="readonly", width=42).pack(side="left", padx=4)
        ttk.Label(barra, text="Fecha (solo reporte 2):").pack(side="left", padx=4)
        self.fecha = tk.StringVar()
        ttk.Entry(barra, textvariable=self.fecha, width=12).pack(side="left", padx=4)
        ttk.Button(barra, text="Ejecutar", command=self.ejecutar_reporte).pack(side="left", padx=8)
        self.tabla = Tabla(self)
        self.tabla.pack(fill="both", expand=True, pady=6)

    def ejecutar_reporte(self):
        _, procedimiento, requiere_fecha = next(r for r in REPORTES if r[0] == self.reporte.get())
        args = ()
        if requiere_fecha:
            if not self.fecha.get().strip():
                messagebox.showwarning("Falta la fecha", "Ingrese la fecha con formato AAAA-MM-DD.")
                return
            args = (self.fecha.get().strip(),)
        resultado = ejecutar(lambda: llamar(procedimiento, args))
        if resultado:
            self.tabla.cargar(*resultado)


# --- Ventana principal -------------------------------------------------
class App(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Stellarium Observatorio y Planetario - Gestion de reservas")
        self.geometry("1220x760")
        self.minsize(1100, 680)
        aplicar_estilo(self)

        # Encabezado: logo a la izquierda y subtitulo a la derecha
        encabezado = tk.Frame(self, bg=BLANCO)
        encabezado.pack(fill="x")
        try:
            self.logo = tk.PhotoImage(file=ruta_recurso("logo_stellarium.png"))
            tk.Label(encabezado, image=self.logo, bg=BLANCO).pack(side="left", padx=24, pady=12)
        except tk.TclError:  # si falta el archivo del logo, se muestra el nombre en texto
            tk.Label(encabezado, text="Stellarium", bg=BLANCO, fg=AZUL_NOCHE,
                     font=(FUENTE, 22, "bold")).pack(side="left", padx=24, pady=16)
        tk.Label(encabezado, text="Gestión de reservas y programación de actividades", bg=BLANCO,
                 fg=TENUE, font=(FUENTE, 10)).pack(side="right", padx=24)
        tk.Frame(self, bg=TURQUESA, height=3).pack(fill="x")  # linea de acento

        pestanas = ttk.Notebook(self)
        pestanas.pack(fill="both", expand=True, padx=16, pady=16)
        pestanas.add(ModuloClientes(pestanas), text="Clientes")
        pestanas.add(ModuloReservas(pestanas), text="Reservas")
        pestanas.add(ModuloReportes(pestanas), text="Reportes")


if __name__ == "__main__":
    App().mainloop()
