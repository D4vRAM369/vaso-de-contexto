# 06 · Siguiente nivel

## Pendiente de verificar

- **Llamada real a los proveedores de IA.** El código está escrito pero no se ha probado con una key. Los nombres de modelo por defecto pueden haber caducado.
- **Applet cargado en el panel.** Sintaxis y funciones comprobadas, pero falta verlo funcionando en Cinnamon.
- **Windows.** Está escrito para ser portable (`pathlib`, sin dependencias), pero solo se ha ejecutado en Linux.

## Simplificaciones conscientes

| Ahora | Límite | Cuándo mejorarlo |
|---|---|---|
| Se relee el archivo entero cuando cambia | Lento con sesiones de cientos de MB | Si notas retraso: leer solo lo añadido desde la última vez |
| Polling cada 3 s | Hasta 3 s de retraso | Si quieres tiempo real: Server-Sent Events |
| 200k o 1M deducido | Una sesión de 1M que no ha pasado de 200k se ve como de 200k | Elegirlo a mano en Ajustes |
| Umbrales fijos | Son criterio personal | Ajustar las constantes de `vaso.py` tras unas semanas de uso |
| Key en `localStorage` | Cualquiera con acceso a tu navegador puede leerla | Si compartes equipo: guardarla en el llavero del sistema |

## Ideas para ampliar

- **Otras herramientas:** leer sesiones de Codex (`~/.codex`) y Gemini CLI (`~/.gemini`). Cada una tiene su formato: haría falta un lector por herramienta que devuelva las mismas métricas.
- **Resumen listo para pegar:** que la IA genere el resumen con el que abrir una sesión nueva.
- **Notificación de escritorio** al cruzar un umbral, para no tener que mirar la página.
- **Ajustes del applet:** intervalo de refresco y avisos configurables con `settings-schema.json`.
- **Equivalente en Windows:** un icono en la bandeja del sistema que consuma el mismo `--json`.
- **Vaso en la terminal:** una statusline de Claude Code que reutilice `parse()` y `advise()`.
- **Coste:** traducir tokens a dinero según el modelo.
- **Varios vasos a la vez:** una fila con todas las sesiones activas.

## Ejercicios para aprendices

1. Cambia los umbrales a 40/60/80 y arregla el test para que vuelva a pasar.
2. Añade un cuarto proveedor compatible con el mismo formato.
3. Haz que el título de la pestaña del navegador muestre el porcentaje.
4. Dibuja una segunda línea en la gráfica con los tokens de salida de cada turno.
