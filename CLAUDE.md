# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Qué es

"Vaso de contexto": página local que muestra un vaso de agua que se llena según el contexto usado por una sesión de Claude Code, con indicadores y consejos de cuándo hacer `/compact`, `/clear` o empezar sesión nueva. Debe funcionar igual en Linux y Windows.

## Comandos

```bash
python3 vaso.py              # arranca en http://127.0.0.1:8765 y abre el navegador (Windows: python vaso.py)
python3 vaso.py --no-browser # sin abrir navegador
python3 vaso.py --test       # autocomprobación (asserts de advise() y parse()); imprime "ok"
python3 vaso.py --json       # estado de la sesión más reciente por stdout (lo consume el applet)
node --check "cinnamon/vaso-contexto@d4vram/applet.js"   # solo sintaxis del applet
cinnamon/empaquetar.sh       # monta en dist/ el paquete para Cinnamon Spices
```

Variables de entorno: `VASO_PORT` (puerto, por defecto 8765) y `CLAUDE_CONFIG_DIR` (si las sesiones no están en `~/.claude`).

No hay build, linter ni dependencias: solo la librería estándar de Python y un HTML sin frameworks. Mantenerlo así; no añadir paquetes ni paso de compilación sin que Brian lo pida.

## Arquitectura

Dos archivos, y la frontera entre ellos importa:

- `vaso.py` — servidor `http.server` en 127.0.0.1. Toda la lógica vive aquí: leer transcripts, calcular métricas, decidir el consejo (`advise`) y hacer de proxy hacia el proveedor de IA.
- `index.html` — solo pinta. Sondea `/api/state` cada 3 s y no calcula nada salvo la geometría del vaso. Las reglas y umbrales no se duplican en JS: llegan en la respuesta (`advice`, `thresholds`).

Endpoints: `GET /api/sessions`, `GET /api/state?s=<proyecto/uuid.jsonl>&limit=<n>` (sin `s` = sesión más reciente), `POST /api/advice`.

### Applet de Cinnamon (solo Linux Mint)

`cinnamon/vaso-contexto@d4vram/` es un applet de panel (CJS, no Node: usa `imports.*`, no `require`). Tampoco calcula nada: cada 10 s ejecuta `python3 vaso.py --json` y pinta porcentaje, icono y desplegable. No necesita el servidor en marcha.

- Se instala como enlace simbólico en `~/.local/share/cinnamon/applets/`; localiza `vaso.py` primero en `metadata.path/vaso.py` (paquete de Spices) y si no en `metadata.path/../../vaso.py` (desarrollo), así que mover la carpeta `cinnamon/` rompe esa segunda ruta.
- Publicación: `cinnamon/empaquetar.sh` genera `dist/<uuid>/` (ignorado por git) copiando dentro `vaso.py` e `index.html`; esa carpeta se copia al fork de `linuxmint/cinnamon-spices-applets`. `cinnamon/README.md` es el README público del applet (en inglés). No guardar copias de `vaso.py` en el repo.
- El nombre de la carpeta debe coincidir con el `uuid` de `metadata.json`.
- Tras editar `applet.js`, recargar con clic derecho en el applet → "Recargar" o reiniciando Cinnamon (Alt+F2, `r`). Los errores salen en Looking Glass (Alt+F2, `lg`) o en `~/.xsession-errors`.
- Los colores de nivel están duplicados a propósito en `COLORS` (applet) y en las variables CSS de `index.html`: cambiarlos en ambos.

### Cómo se mide el contexto (lo no obvio)

Fuente: `~/.claude/projects/<proyecto>/<uuid>.jsonl`, una línea JSON por evento.

- Contexto de un turno = `input_tokens + cache_creation_input_tokens + cache_read_input_tokens` del `message.usage` de las líneas `type: "assistant"`. El nivel del vaso es eso más `output_tokens` (la salida será entrada del turno siguiente).
- Una misma respuesta ocupa varias líneas con el mismo `requestId` y el mismo `usage`: se deduplica por `requestId` quedándose la última.
- Se ignoran `isSidechain: true` (subagentes) y `model: "<synthetic>"`.
- `type: "system", subtype: "compact_boundary"` marca una compactación; `compactMetadata.postTokens` es el nivel nuevo y `preTokens` cuenta para el pico.
- El transcript no dice si la ventana es de 200k o 1M: se deduce (pico > 200k ⇒ 1M) y la página permite forzarlo.
- El formato del transcript es interno de Claude Code y cambia entre versiones: `parse()` debe tolerar campos ausentes y líneas rotas.

### Consejos

`advise(pct, idle_min, compactions)` usa las constantes `WATCH`/`COMPACT`/`NEW` (0.50/0.70/0.85) y `COLD_CACHE_MIN`, definidas arriba en `vaso.py`. Son el mando de calibración; si cambian, actualizar los asserts de `test()`.

### BYOK

Gemini, Groq y OpenRouter se llaman por su endpoint compatible con OpenAI (`PROVIDERS`), con una única función `ask_ai`. La key vive en `localStorage` del navegador y viaja a `vaso.py` en cada petición; el servidor no la guarda ni la registra. Las URLs de proveedor son una lista cerrada: no aceptar URLs arbitrarias desde la página.

### Seguridad que no hay que quitar

- Escucha solo en 127.0.0.1 y valida la cabecera `Host` (DNS rebinding): los transcripts son privados.
- `resolve()` impide salir de la carpeta de sesiones.
- `/api/state` no devuelve el texto de los mensajes; solo `ask_ai` lo usa, y solo cuando el usuario pulsa el botón.
- El texto de la IA y los títulos de sesión se insertan con `textContent`, nunca `innerHTML`.

## Documentación PBL (Chronicler)

`docs/` se mantiene con la skill `chronicler`: cada cambio de código actualiza `03_PASO_A_PASO.md`; cada error real, `05_ERRORES_Y_SOLUCIONES.md`; cada término nuevo, `00_GLOSARIO.md`; cada decisión, `02_ARQUITECTURA.md`. Escrita en español, desde cero, para Brian y aprendices sin experiencia. No reescribir la historia: los intentos fallidos también se documentan.
