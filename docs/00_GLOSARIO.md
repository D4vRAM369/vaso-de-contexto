# Glosario del Proyecto

> Aquí están todos los términos técnicos que aparecen en la documentación, explicados en lenguaje humano.
> Si lees algo que no entiendes, búscalo aquí primero.

---

## Token

**Definición simple:** El trocito de texto con el que un modelo de IA cuenta lo que lee y escribe.

**Definición técnica:** Unidad en la que el modelo divide el texto antes de procesarlo. Una palabra corta suele ser un token; una larga, dos o tres. En español, 1000 tokens rondan las 700 palabras.

**Analogía:** Los mililitros del vaso. No mides el agua en "sorbos" sino en una unidad fija.

**En este proyecto lo usamos para:** Medir cuánto de lleno está el contexto.

---

## Contexto (ventana de contexto)

**Definición simple:** Todo lo que el modelo tiene delante al responderte: la conversación entera hasta ahora.

**Definición técnica:** El conjunto de tokens de entrada de una petición. Tiene un máximo (aquí 200 000 o 1 000 000 según la sesión). El modelo no recuerda nada entre mensajes: se le reenvía todo cada vez.

**Analogía:** El vaso. Cada mensaje añade agua; el vaso no crece.

**En este proyecto lo usamos para:** Es exactamente lo que dibujamos.

---

## Compactar (`/compact`)

**Definición simple:** Pedirle a Claude Code que sustituya la conversación por un resumen.

**Definición técnica:** Se genera un resumen del historial y la sesión continúa solo con él. Libera contexto a cambio de perder detalle. Si no lo haces tú, Claude Code lo hace solo al llenarse (autocompactación).

**Analogía:** Hervir el agua hasta dejar un concentrado: ocupa menos, pero ya no es lo mismo.

**En este proyecto lo usamos para:** Es uno de los tres consejos. También lo detectamos en el historial para contar cuántas veces ha pasado.

---

## `/clear`

**Definición simple:** Vaciar la conversación del todo y seguir en la misma ventana.

**Analogía:** Tirar el agua y empezar con el vaso vacío. Ideal al cambiar de tema.

---

## Caché (prompt caching)

**Definición simple:** Un atajo por el que releer lo que el modelo ya leyó hace poco cuesta mucho menos.

**Definición técnica:** El proveedor guarda durante unos minutos el prefijo ya procesado de la conversación. Mientras está "caliente", esos tokens se cobran a una fracción del precio. Si pasas mucho rato sin escribir, caduca ("frío") y el siguiente mensaje paga todo a precio completo.

**Analogía:** Dejar la olla en el fuego. Si sigues cocinando, ya está caliente; si te vas una hora, toca calentarla entera otra vez.

**En este proyecto lo usamos para:** La barra "Caché leída" y el aviso de caché frío: si de todos modos vas a pagar la relectura completa, es el mejor momento para compactar o limpiar.

---

## Transcript

**Definición simple:** El archivo donde Claude Code va apuntando todo lo que pasa en una sesión.

**Definición técnica:** Archivo `.jsonl` en `~/.claude/projects/<proyecto>/<id>.jsonl`.

**En este proyecto lo usamos para:** Es nuestra única fuente de datos. No preguntamos nada a Claude: leemos su diario.

---

## JSON / JSONL

**Definición simple:** JSON es una forma de escribir datos como texto con etiquetas. JSONL es un archivo con un JSON por línea.

**Analogía:** JSON es una ficha rellenada; JSONL es un fichero donde cada renglón es una ficha.

**Por qué JSONL:** Para añadir un dato nuevo basta escribir una línea al final, sin reescribir el archivo. Perfecto para un diario que crece.

**Ejemplo:**
```json
{"type": "assistant", "message": {"usage": {"input_tokens": 10, "output_tokens": 50}}}
```

---

## Servidor local / localhost / 127.0.0.1

**Definición simple:** Un programa en tu propio ordenador que responde a tu navegador, sin salir a internet.

**Definición técnica:** `127.0.0.1` (alias `localhost`) es la dirección que significa "esta misma máquina". Un servidor que escucha ahí no es visible desde otros equipos.

**Analogía:** Un interfono interno de casa: funciona, pero nadie de la calle puede llamar.

**En este proyecto lo usamos para:** Una página web no puede leer archivos de tu disco; el servidor los lee y se los pasa.

---

## Puerto

**Definición simple:** El número de "puerta" por la que se entra a un programa dentro de un ordenador. El nuestro es el 8765.

**Analogía:** La dirección es el edificio; el puerto, el número de piso.

---

## Endpoint / API

**Definición simple:** Una API es el menú de cosas que un programa ofrece a otros programas. Cada plato del menú es un endpoint.

**En este proyecto:** `/api/state` devuelve el estado del vaso; `/api/sessions`, la lista de sesiones; `/api/advice`, el consejo con IA.

---

## fetch / polling

**Definición simple:** `fetch` es la orden de JavaScript para pedir datos a un servidor. *Polling* es repetir esa petición cada cierto tiempo.

**Analogía:** Mirar el buzón cada 3 segundos por si ha llegado carta.

**En este proyecto lo usamos para:** Que el vaso se actualice solo.

---

## SVG

**Definición simple:** Una forma de describir dibujos con texto (líneas, curvas, colores) en lugar de píxeles.

**Por qué importa:** Se ve nítido a cualquier tamaño y se puede animar y recolorear con CSS.

**En este proyecto lo usamos para:** El vaso, el agua y la gráfica de evolución.

---

## BYOK (Bring Your Own Key)

**Definición simple:** "Trae tu propia llave": la app no incluye acceso de pago a ninguna IA; tú pones tu clave.

**Analogía:** Un local de "trae tu bebida": ellos ponen la mesa, tú la botella.

**En este proyecto lo usamos para:** El consejo con IA, usando claves gratuitas de Gemini, Groq u OpenRouter.

---

## API key

**Definición simple:** Una contraseña larga que identifica tu cuenta ante un servicio. Quien la tenga puede gastar tu cuota: no se comparte ni se sube a un repositorio.

---

## localStorage

**Definición simple:** Un cajón que el navegador le da a cada página para guardar pequeños datos entre visitas.

**En este proyecto lo usamos para:** Recordar tu proveedor, tu key y tu modelo. Se queda en tu navegador.

---

## Librería estándar

**Definición simple:** Las herramientas que vienen incluidas con Python, sin instalar nada aparte.

**En este proyecto lo usamos para:** Todo. Por eso funciona en Windows y Linux sin pasos de instalación.

---

## Proxy

**Definición simple:** Un intermediario que hace una petición en tu nombre.

**En este proyecto lo usamos para:** La página no llama a Gemini directamente; se lo pide a `vaso.py`, que hace la llamada.

---

## DNS rebinding

**Definición simple:** Un truco por el que una web maliciosa consigue que tu navegador hable con un programa local creyendo que habla con ella.

**En este proyecto:** Lo bloqueamos comprobando que la petición viene dirigida a `127.0.0.1:8765` o `localhost:8765`.

---

## Applet (Cinnamon)

**Definición simple:** Un mini programa que vive en la barra de tareas de Linux Mint: el reloj, el volumen y la red son applets.

**Definición técnica:** Una carpeta con `metadata.json` y `applet.js` que el escritorio Cinnamon carga dentro de su propio proceso.

**En este proyecto lo usamos para:** Tener el vaso siempre a la vista en el panel.

---

## Cinnamon Spices

**Definición simple:** La "tienda" gratuita de complementos de Linux Mint. Lo que aparece en la pestaña **Descargar** de la ventana de applets sale de ahí.

**Definición técnica:** Un repositorio de GitHub por tipo de complemento (`linuxmint/cinnamon-spices-applets` para applets). Se publica con un pull request; cada applet es una carpeta `<uuid>/` con `info.json`, `README.md`, `screenshot.png` y `files/<uuid>/` con el código.

**En este proyecto lo usamos para:** Que otras personas instalen el vaso sin clonar el proyecto.

---

## Fork

**Definición simple:** Tu copia personal, en GitHub, de un repositorio ajeno. Cambias tu copia y luego propones esos cambios al original.

**En este proyecto lo usamos para:** Proponer el applet al repositorio de Cinnamon Spices, donde no tenemos permiso de escritura.

---

## Desklet

**Definición simple:** Como un applet, pero flota sobre el fondo de escritorio en vez de estar en el panel. Lo descartamos porque las ventanas lo tapan.

---

## Enlace simbólico (symlink)

**Definición simple:** Un acceso directo: un nombre en una carpeta que apunta a un archivo o carpeta que está en otro sitio.

**En este proyecto lo usamos para:** Que Cinnamon encuentre el applet en su carpeta de applets mientras el código real sigue en el proyecto.

---

## Asíncrono

**Definición simple:** Encargar una tarea y seguir a lo tuyo; cuando termina, te avisan.

**Analogía:** Pedir en un bar y que te llamen por tu nombre, en vez de quedarte plantado en la barra bloqueando la cola.

**En este proyecto lo usamos para:** Que el panel no se congele mientras Python lee la sesión.

---

## stdout

**Definición simple:** El "altavoz" por el que un programa de terminal suelta su resultado. Otro programa puede escucharlo.

**En este proyecto lo usamos para:** `vaso.py --json` imprime por stdout y el applet lo recoge.

---

## Subagente (sidechain)

**Definición simple:** Un ayudante que Claude lanza para una subtarea, con su propio vaso aparte.

**En este proyecto:** Sus líneas (`isSidechain`) se ignoran porque no llenan el vaso principal.

---
