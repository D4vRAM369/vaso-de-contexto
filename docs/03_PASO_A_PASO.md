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

## Resumen de Sesión 1 — 13/10/2026

**Progreso:** de carpeta vacía a herramienta funcionando: servidor, vaso animado, indicadores, consejos por reglas, selector de sesión, BYOK, repositorio git y applet de Cinnamon.

**Conceptos nuevos:** tokens y contexto, JSONL, servidor local, SVG con `clipPath`, polling, BYOK.

**Errores encontrados y resueltos:** cálculo del crecimiento siempre a cero (ver `05`).

**Verificado:** autotest `ok`; la página muestra datos reales de la sesión en curso, sin errores en consola.

**Sin verificar:** la llamada a los proveedores de IA (no había key), la ejecución en Windows y el applet cargado en un panel real.

**Próximo paso:** probar con una key gratuita y en Windows.
