# 03 · Paso a paso

> Cómo se construyó, en el orden real. El código completo está en `vaso.py` e `index.html`; aquí van los fragmentos que importan y su porqué.

## Sesión 1 — 13 de octubre de 2026

**Punto de partida:** carpeta vacía y una idea: "un vaso que se llena según el contexto de la conversación".

---

## Paso 1: Descubrir de dónde sacar el dato

**Qué vamos a hacer:** Averiguar si existe un sitio donde ya esté apuntado cuánto contexto usa una sesión.

**Por qué lo hacemos así:** Antes de construir un medidor, mira si alguien ya está midiendo. Leer un dato exacto siempre gana a estimarlo.

**Resultado esperado:** Saber qué archivo leer y qué campos mirar.

### Instrucciones

Claude Code guarda cada sesión en `~/.claude/projects/<proyecto>/<id>.jsonl`. Abrimos la más reciente y buscamos la palabra `usage`:

```json
"usage": {
  "input_tokens": 2,
  "cache_creation_input_tokens": 37787,
  "cache_read_input_tokens": 36647,
  "output_tokens": 454
}
```

Ahí está todo. El modelo leyó en ese turno `2 + 37787 + 36647 = 74 436` tokens. Los tres números son la misma cosa (texto que entra) repartida según cómo se cobra: nuevo, recién guardado en caché, y leído de caché.

> 💡 **Nota para aprendices:** `input_tokens: 2` engaña. Parece que el contexto es minúsculo, pero es solo la parte *no cacheada*. Hay que sumar los tres.

**Verificación:** el archivo existe y contiene líneas con `"usage"`.

---

## Paso 2: Leer el diario y quedarnos con lo que cuenta

**Qué vamos a hacer:** La función `parse()`, que recorre el archivo y devuelve las métricas.

**Por qué lo hacemos así:** El archivo mezcla decenas de tipos de línea (mensajes, títulos, adjuntos, marcas internas). Nos interesan cuatro; el resto se ignora.

**Resultado esperado:** Un diccionario con `used`, `turns`, `compactions`, `growth`…

### Instrucciones

```python
with open(path, encoding="utf-8", errors="replace") as f:
    for line in f:
        try:
            d = json.loads(line)
        except ValueError:
            continue  # línea a medio escribir mientras Claude Code guarda
```

Leemos línea a línea (no el archivo entero de golpe) y, si una línea no es JSON válido, la saltamos: Claude Code puede estar escribiendo justo en ese instante.

Tres trampas que hubo que resolver:

**a) Una respuesta ocupa varias líneas.** Si Claude contesta con texto y luego usa dos herramientas, eso son tres líneas con el mismo `requestId` y el mismo `usage`. Contarlas todas triplicaría los turnos. Solución: un diccionario cuya llave es el `requestId`; cada línea nueva pisa la anterior.

```python
turns[d.get("requestId") or d.get("uuid")] = (timestamp, ctx, out, cache_read)
```

**b) Los subagentes.** Tienen su propio contexto. Llevan `isSidechain: true` y se saltan.

**c) El nivel real incluye la respuesta.** Lo que el modelo acaba de escribir será entrada en el turno siguiente:

```python
used = ctx + out
```

Las compactaciones dejan una línea propia con el antes y el después:

```python
if t == "system" and d.get("subtype") == "compact_boundary":
    compactions += 1
    used = meta.get("postTokens") or used   # el vaso baja de golpe
```

> ⚠️ **Errores comunes:** este formato es interno de Claude Code y nadie garantiza que no cambie. Por eso todo se lee con `.get()` (devuelve `None` si el campo no existe) en vez de `d["campo"]` (que rompe el programa).

**Verificación:** `python3 vaso.py --test` imprime `ok`.

---

## Paso 3: Las reglas del consejo

**Qué vamos a hacer:** `advise(pct, idle_min, compactions)`.

**Por qué lo hacemos así:** Una función que recibe tres números y devuelve un consejo se puede probar sin navegador ni archivos. Eso la hace fiable.

### Instrucciones

```python
WATCH, COMPACT, NEW = 0.50, 0.70, 0.85

def advise(pct, idle_min, compactions):
    if pct >= NEW:        ...  # sesión nueva
    elif pct >= COMPACT:  ...  # /compact ya
    elif pct >= WATCH:    ...  # en el próximo corte
    else:                 ...  # sigue
```

Se comprueba de mayor a menor: así cada `elif` solo necesita el límite inferior.

Dos avisos extra que no dependen del nivel:

- **Caché frío** (más de 60 min sin actividad): el próximo mensaje pagará la relectura completa. Si vas a compactar, ese es el momento más barato.
- **Dos o más compactaciones:** un resumen de un resumen pierde detalle. Mejor sesión nueva.

**Verificación:** los `assert` de `test()` cubren cada frontera (0.50, 0.70, 0.85).

---

## Paso 4: El servidor

**Qué vamos a hacer:** Servir la página y tres direcciones con datos.

**Por qué lo hacemos así:** Una página web no puede abrir archivos de tu disco (por seguridad). Python sí. El servidor es el puente. Usamos `http.server`, que ya viene con Python.

### Instrucciones

```python
srv = ThreadingHTTPServer(("127.0.0.1", PORT), Handler)
```

`127.0.0.1` y no `0.0.0.0`: lo segundo abriría el servidor a toda tu red wifi, con tus conversaciones dentro.

| Dirección | Devuelve |
|---|---|
| `/` | `index.html` |
| `/api/sessions` | las 25 sesiones más recientes |
| `/api/state` | métricas + consejo de una sesión |
| `/api/advice` (POST) | el consejo de la IA |

Para que el mismo código valga en Windows y Linux, las rutas se construyen con `pathlib`:

```python
ROOT = Path.home() / ".claude" / "projects"
```

`Path.home()` da `/home/brian` o `C:\Users\Brian` según toque, y `/` pone la barra correcta.

**Verificación:** con el servidor arrancado, abre `http://127.0.0.1:8765/api/state` y verás el JSON.

---

## Paso 5: Dibujar el vaso

**Qué vamos a hacer:** Un SVG con un vaso, agua que sube y una ola que se mueve.

**Por qué lo hacemos así:** SVG permite recortar una forma con otra (`clipPath`). El agua es un bloque grande; el recorte con forma de vaso hace que solo se vea lo de dentro. Subir el nivel es mover el bloque hacia arriba, nada más.

### Instrucciones

```html
<g clip-path="url(#inside)">
  <g id="water" style="transform: translateY(260px)">
    <path id="wave" d="M0 10 Q25 2 50 10 T100 10 … V300 H0 Z"/>
  </g>
</g>
```

```js
// Fondo del vaso en y=270, borde en y=20 → 250 px de recorrido.
const levelY = f => 270 - Math.min(f, 1) * 250;
$('water').style.transform = `translateY(${levelY(s.pct) - 10}px)`;
```

En SVG la `y` crece hacia abajo, por eso se resta. La transición suave la pone CSS (`transition: transform 1.2s`); JavaScript solo dice dónde.

La ola es la misma curva repetida cada 100 px, desplazándose 100 px en bucle: al acabar está idéntica a como empezó y el salto no se nota.

El color cambia con el nivel de aviso mediante una variable CSS (`--water`): se cambia en un sitio y lo siguen el agua, las barras y el borde del consejo.

> 💡 **Nota para aprendices:** `@media (prefers-reduced-motion: reduce)` apaga la animación para quien tiene activada la opción de "reducir movimiento" en su sistema. Hay personas a las que una ola constante les marea.

**Verificación:** el vaso se llena al porcentaje que marca el número de debajo.

---

## Paso 6: Que se actualice solo

```js
setInterval(refresh, 3000);
```

Cada 3 segundos la página pide `/api/state` y redibuja. El servidor guarda en memoria el último resultado de cada archivo y solo lo relee si ha cambiado (compara fecha y tamaño), así que preguntar a menudo no cuesta nada.

---

## Paso 7: BYOK — el consejo con IA

**Qué vamos a hacer:** Un botón que manda las métricas y tus 6 últimos mensajes (recortados a 300 caracteres) a un modelo gratuito.

**Por qué lo hacemos así:** Gemini, Groq y OpenRouter aceptan el mismo formato de petición (el que popularizó OpenAI). Solo cambia la dirección:

```python
PROVIDERS = {
    "gemini": "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions",
    "groq": "https://api.groq.com/openai/v1/chat/completions",
    "openrouter": "https://openrouter.ai/api/v1/chat/completions",
}
```

Una función, tres proveedores. La key viaja en la cabecera `Authorization: Bearer <key>`.

> ⚠️ **Errores comunes:** un nombre de modelo caducado devuelve error 404 o 400. El mensaje del proveedor se muestra tal cual en la página para que sepas qué corregir.

**Verificación:** pendiente de probar con una key real (ver resumen de sesión).

---

## Paso 8: Primer commit con git

Se inicializó el repositorio y se hizo el primer commit. Ver el error de `.omc/` en `05_ERRORES_Y_SOLUCIONES.md`: `git add -A` añade *todo*, también lo que no es tuyo.

---

## Paso 9: Una salida para otros programas (`--json`)

**Qué vamos a hacer:** Que `vaso.py` pueda imprimir el estado y salir, sin arrancar el servidor.

**Por qué lo hacemos así:** El applet necesita los mismos datos que la página. En vez de reescribir la lectura en otro lenguaje, le damos al programa una segunda puerta de salida.

```python
elif "--json" in sys.argv:
    p = resolve("")
    s = state(p) if p else {"error": f"No hay sesiones en {ROOT}"}
    s.pop("msgs", None)
    print(json.dumps(s))
```

Son las mismas funciones `resolve` y `state` del servidor. Cero lógica nueva.

**Verificación:** `python3 vaso.py --json` imprime una línea que empieza por `{"title": ...`.

---

## Paso 10: El applet de Cinnamon

**Qué vamos a hacer:** Un icono en el panel con el vaso y el porcentaje, y un desplegable con el consejo.

**Por qué lo hacemos así:** La página obliga a ir a mirarla. El panel está siempre a la vista.

**Resultado esperado:** `cinnamon/vaso-contexto@d4vram/` con dos archivos.

### Instrucciones

Un applet de Cinnamon es una carpeta con, como mínimo:

- `metadata.json`: la ficha (nombre, descripción y un identificador único, el `uuid`). **La carpeta debe llamarse igual que el `uuid`.**
- `applet.js`: el código. Cinnamon busca en él una función `main()` que devuelva el applet.

El esqueleto:

```js
class VasoApplet extends Applet.TextIconApplet {   // un applet con icono y texto
    constructor(metadata, orientation, panelHeight, instanceId) {
        super(orientation, panelHeight, instanceId);
        this.refresh();
        this.timer = Mainloop.timeout_add_seconds(10, () => { this.refresh(); return true; });
    }
}
```

`return true` le dice al temporizador "vuelve a llamarme"; con `false` se pararía.

Pedir los datos es ejecutar el script y leer lo que imprime:

```js
Util.spawnCommandLineAsyncIO(`python3 ${this.script} --json`, (stdout, stderr) => {
    const s = JSON.parse(stdout);
    this.render(s);
});
```

"Async" importa: el applet vive dentro del propio escritorio. Si esperase bloqueado a que Python termine, **se congelaría todo el panel** ese rato.

Dos detalles con trampa:

**a) La ruta tiene espacios.** La carpeta se llama "Vaso de contexto". Sin comillas, la terminal entendería tres argumentos. `GLib.shell_quote()` las pone bien.

**b) El icono que se llena.** Se genera un SVG pequeño según el nivel y se guarda en la caché del usuario con un nombre distinto por nivel y color (`vaso-watch-11.svg`). El nombre distinto es necesario: Cinnamon recuerda las imágenes por su ruta y, si se sobrescribiera siempre el mismo archivo, seguiría mostrando la antigua.

Por último, una notificación de escritorio, pero solo al **subir** a "compacta ya" o "sesión nueva":

```js
if (this.level !== null && RANK[a.level] > RANK[this.level] && RANK[a.level] >= RANK.compact)
    Main.notify(`Vaso de contexto: ${a.title}`, a.text);
```

Sin esa condición avisaría cada 10 segundos. `this.level !== null` evita el aviso nada más arrancar.

> 💡 **Nota para aprendices:** el JavaScript de Cinnamon (CJS) no es el del navegador ni Node. No hay `document`, ni `fetch`, ni `require`. Las piezas se traen con `imports.ui.applet`, `imports.gi.GLib`, etc.

**Verificación:** hecha la sintaxis (`node --check`), la salida `--json` y la existencia de cada función usada en el Cinnamon 6.6.9 instalado. Cargado en el panel el 14/10/2026: funciona; el texto del desplegable salía atenuado (ver `05_ERRORES_Y_SOLUCIONES.md`).

---

## Sesión 2 — 14 de octubre de 2026

## Paso 11: Preparar el applet para Cinnamon Spices

**Problema:** el applet buscaba `vaso.py` dos carpetas por encima de la suya. Eso funciona en desarrollo (el applet es un enlace simbólico al proyecto), pero Cinnamon Spices solo instala la carpeta del applet: esas dos carpetas de arriba no existen en el equipo de otra persona.

**Analogía:** una receta que dice "coge la sal del armario de mi cocina" solo sirve en mi casa. Para repartirla hay que meter la sal en la caja.

### Instrucciones

**a) El applet mira primero dentro de su carpeta** y, si no encuentra `vaso.py`, usa la ruta de desarrollo:

```js
const bundled = GLib.build_filenamev([metadata.path, 'vaso.py']);
this.script = GLib.shell_quote(GLib.file_test(bundled, GLib.FileTest.EXISTS)
    ? bundled : GLib.build_filenamev([metadata.path, '..', '..', 'vaso.py']));
```

**b) Un script monta el paquete** con la forma que pide Spices:

```bash
cinnamon/empaquetar.sh
```

Resultado en `dist/vaso-contexto@d4vram/`:

```
info.json            ← autor (usuario de GitHub)
README.md            ← copia de cinnamon/README.md, en inglés
screenshot.png       ← copia de cinnamon/screenshot.png
files/vaso-contexto@d4vram/
    metadata.json, applet.js, icon.png
    vaso.py, index.html   ← copiados desde la raíz del proyecto
```

`index.html` también viaja porque el botón "Abrir página completa" arranca `vaso.py`, y este busca la página junto a sí mismo.

**c) Icono y versión.** `icon.png` es lo que se ve en la lista de applets; se generó una vez a partir del mismo dibujo SVG del vaso. `metadata.json` gana el campo `version`.

**d) Enviarlo** (se hace a mano, fuera de este proyecto): fork de `linuxmint/cinnamon-spices-applets`, copiar `dist/vaso-contexto@d4vram` a su raíz, ejecutar allí `./validate-spice vaso-contexto@d4vram`, y abrir el pull request.

> ⚠️ **Errores comunes:** editar los archivos de `dist/`. Se borran y regeneran en cada empaquetado; los cambios se hacen en el proyecto.

**Verificación:** con el paquete generado, `node --check` del applet, `vaso.py --test` (`ok`) y `vaso.py --json` ejecutados **desde la copia de `dist/`** funcionan. El validador oficial (`./validate-spice`) da `No errors found` una vez añadida la captura. **Sin verificar:** la instalación real desde la pestaña Descargar.

**e) Captura sin metadatos.** Una imagen puede llevar datos ocultos (programa usado, fecha, a veces ubicación). Antes de publicarla se limpian:

```bash
exiftool -all= -overwrite_original cinnamon/screenshot.png
```

`-all=` significa "todas las etiquetas, a vacío"; `-overwrite_original` evita que deje una copia `_original` al lado.

**f) Licencia.** Spices exige código abierto: se añade `LICENSE` (MIT) en la raíz.

---

## Paso 12: Atender al revisor automático de Spices

Al abrir el pull request, un robot del repositorio de Mint repasó el código y dejó cuatro avisos de dos tipos.

**a) Comandos como texto de shell.** Lanzábamos `python3 "ruta" --json` como una frase que interpreta una shell, y por eso había que entrecomillar la ruta. La alternativa es una **lista de argumentos** (argv): cada pieza por separado, sin shell de por medio.

```js
Util.spawn(['python3', this.script]);
Gio.Subprocess.new(['python3', this.script, '--json'], flags);
```

(Primer intento: `Util.spawnCommandLineAsyncIO` con su opción `argv`. Funcionaba, pero el robot busca por el **nombre** de la función y seguía avisando. Usar `Gio.Subprocess` directamente es lo mismo que hacía esa función por dentro, sin el falso positivo.)

**Analogía:** dictar un pedido de corrido ("dos cafés con leche y uno solo") frente a entregar una lista con una línea por producto. En la lista no hay dudas de dónde acaba cada cosa, aunque el nombre lleve espacios.

**b) Preguntar al disco de forma síncrona.** `GLib.file_test()` detiene todo el panel hasta que el disco responde. Se usaba en dos sitios:

- Para decidir dónde estaba `vaso.py`. Solución: que esté **siempre** dentro de la carpeta del applet. En el proyecto es un enlace simbólico (`vaso.py -> ../../vaso.py`); `empaquetar.sh` lo convierte en copia real con `cp -rL`. Ya no hay nada que preguntar.
- Para no reescribir un icono ya creado. Solución: recordarlo en memoria (`this.icons`, un `Set`) y escribir el archivo de forma asíncrona con `Gio`; el icono se coloca cuando la escritura termina.

**Verificación:** probado en `cjs` (el motor de Cinnamon) y recargando el applet en el panel real: carga sin errores y escribe los iconos. `./validate-spice` sigue sin errores.

---

## Paso 13: Un paquete sin el botón de IA

**Problema:** queremos dos versiones del mismo programa (con botón de IA y sin él) sin mantener dos copias del código.

**Analogía:** un guion con escenas marcadas con fosforito "solo versión extendida". Hay un único guion; al imprimir la versión corta, se saltan las escenas marcadas.

### Instrucciones

**a) Marcar** cada trozo del botón de IA, en `vaso.py` y en `index.html`:

```python
# byok:inicio
def ask_ai(provider, key, model, s):
    ...
# byok:fin
```

En HTML la marca va en un comentario `<!-- byok:inicio -->`; en JavaScript, `// byok:inicio`. Lo único que importa es que el texto aparezca en la línea.

**b) Borrar al empaquetar.** `sed` es un editor de texto por comandos; esta orden significa "borra (`d`) desde la línea que contenga `byok:inicio` hasta la que contenga `byok:fin`":

```bash
sed '/byok:inicio/,/byok:fin/d' vaso.py > dist/.../vaso.py
```

**c) Cinturón de seguridad.** Después, el script busca restos (`urllib.request`, `PROVIDERS`, `/api/advice`…) y, si encuentra alguno, se detiene con error. Así un bloque nuevo sin marcar no se cuela en el paquete sin que nos enteremos.

> ⚠️ **Errores comunes:** dejar fuera de las marcas algo que usa lo de dentro. Al borrar el bloque, lo de fuera se queda llamando a algo que ya no existe. Por eso hubo que mover una línea (`$('limit').value = …`) que estaba en medio del bloque.

**Verificación:** la copia recortada pasa `vaso.py --test` y `--json`; no importa `urllib.request`; su JavaScript no tiene errores de sintaxis ni referencias a elementos que ya no existen. La versión completa sigue funcionando en el navegador con su botón. **Sin verificar:** la página recortada abierta en un navegador.

---

## Resumen de Sesión 1 — 13/10/2026

**Progreso:** de carpeta vacía a herramienta funcionando: servidor, vaso animado, indicadores, consejos por reglas, selector de sesión, BYOK, repositorio git y applet de Cinnamon.

**Conceptos nuevos:** tokens y contexto, JSONL, servidor local, SVG con `clipPath`, polling, BYOK.

**Errores encontrados y resueltos:** cálculo del crecimiento siempre a cero (ver `05`).

**Verificado:** autotest `ok`; la página muestra datos reales de la sesión en curso, sin errores en consola.

**Sin verificar:** la llamada a los proveedores de IA (no había key), la ejecución en Windows y el applet cargado en un panel real.

**Próximo paso:** probar con una key gratuita y en Windows.
