# 02 · Arquitectura: decisiones y por qué

## El dibujo general

```
 Claude Code ──escribe──▶ ~/.claude/projects/…/sesion.jsonl
                                      │ lee
                                      ▼
                                  vaso.py  ──(solo si pulsas el botón)──▶ Gemini / Groq / OpenRouter
                                      ▲
                          pregunta cada 3 s
                                      │
                                 index.html  (tu navegador)
```

Claude Code no sabe que existimos. Él escribe su diario; nosotros lo leemos. No hay plugin, ni hook, ni nada que pueda romper tu sesión.

## Decisión 1 — ¿Qué forma tiene la herramienta?

| Página local | Plugin de Claude Code | Artifact de claude.ai | App de escritorio |
|---|---|---|---|
| ✅ Lee las sesiones en vivo | ✅ Integrado en la terminal | ✅ Nada que arrancar | ✅ Ventana propia |
| ✅ Mismo código en Linux y Windows | ❌ Sin gráficos de verdad | ❌ No puede leer tu disco: habría que pegar datos a mano | ❌ Un build por sistema |
| ✅ Sin instalar nada | | | ❌ Mucha más complejidad |
| ❌ Hay que arrancar un script | | | |

**Elegida: página local.** Es la única que cumple a la vez "vaso gráfico", "vinculado a la conversación" y "Linux y Windows" sin instalar nada.

## Decisión 2 — ¿De dónde salen los números?

Podíamos **estimar** tokens contando caracteres, o **leer** los reales. Claude Code apunta en cada respuesta cuántos tokens leyó el modelo (`usage`). Leemos eso: es el dato exacto y gratis.

Consecuencia: solo funciona con sesiones de Claude Code. Codex, Gemini CLI o texto pegado quedan fuera (ver `06_SIGUIENTE_NIVEL.md`).

## Decisión 3 — ¿Quién piensa, el servidor o la página?

Todo el cálculo está en `vaso.py`. La página solo dibuja lo que recibe.

Por qué: las reglas en un solo sitio se pueden probar (`--test`) y no se desincronizan. Si los umbrales estuvieran también en JavaScript, tarde o temprano uno diría 70 % y el otro 75 %.

## Decisión 4 — ¿Para qué la IA, si ya hay reglas?

Las reglas saben **cuánto** de lleno está el vaso. No saben **de qué** estás hablando. La diferencia entre `/compact` y `/clear` depende de si has cambiado de tema, y eso solo lo ve algo que lea los mensajes.

Por eso: reglas siempre (sin key, sin internet) y la IA como segunda opinión opcional. Sin key la herramienta está completa.

## Decisión 5 — ¿Por qué las llamadas a la IA pasan por `vaso.py`?

La página podría llamar al proveedor directamente, pero los navegadores bloquean por defecto las peticiones entre sitios distintos (política CORS) y cada proveedor lo trata a su manera. Pasando por el servidor Python, ese problema no existe y los tres proveedores usan el mismo código, porque los tres aceptan el mismo formato de petición.

## Decisión 6 — ¿Dónde se guarda la key?

En `localStorage` del navegador. No en un archivo del proyecto (acabaría subida a GitHub por accidente) ni en el servidor (que no guarda nada).

## Decisión 7 — ¿200k o 1M?

El diario no dice de qué tamaño es el vaso de cada sesión. Regla: si alguna vez pasó de 200 000 tokens, es de 1M; si no, suponemos 200k. Como es una suposición, en Ajustes se puede forzar.

## Decisión 8 — La miniapp de Cinnamon: ¿applet o desklet?

| Applet de panel | Desklet de escritorio |
|---|---|
| ✅ Siempre visible, también con ventanas maximizadas | ✅ Espacio para dibujar un vaso grande |
| ✅ Ocupa lo que un icono | ❌ Queda tapado por las ventanas justo cuando trabajas |
| ❌ Poco espacio: icono y un número | |

**Elegido: applet.** Un aviso que no se ve cuando lo necesitas no avisa.

## Decisión 9 — ¿Cómo obtiene los datos el applet?

| Preguntar al servidor web | Ejecutar `vaso.py --json` |
|---|---|
| ✅ Reutiliza `/api/state` | ✅ Funciona sin tener nada arrancado |
| ❌ Si el servidor no está en marcha, el applet no muestra nada | ✅ Reutiliza las mismas funciones |
| ❌ Habría que arrancarlo y vigilarlo desde el applet | ❌ Lanza un proceso Python cada 10 s |

**Elegido: ejecutar el script.** Medimos antes de decidir: leer la sesión más grande del equipo tarda 0,13 s. Con ese coste, un proceso cada 10 segundos es despreciable y nos ahorra toda la gestión del servidor.

La regla de la Decisión 3 se mantiene: el applet tampoco piensa. Ya hay dos "salas" (página y applet) y una sola "cocina".

## Decisión 10 — Publicar el applet: ¿un repositorio o dos?

Para que cualquiera con Linux Mint pueda instalar el applet desde **Applets → Descargar**, hay que subirlo a Cinnamon Spices (ver glosario). Eso obliga a que una copia viva en el repositorio de Mint. La duda es dónde vive el original.

| Un repositorio (este) + el fork de Spices | Repositorio propio para el applet |
|---|---|
| ✅ Una sola fuente de verdad: `vaso.py` existe una vez | ❌ `vaso.py` duplicado en dos sitios que hay que mantener iguales |
| ✅ Un cambio en el formato del diario se arregla en un sitio | ❌ Dos historiales, dos listas de incidencias |
| ❌ Hay que copiar a mano al fork en cada versión | ✅ El applet se ve como proyecto independiente |

**Elegido: un repositorio.** El applet no es un programa aparte: es una "sala" más de la misma "cocina" (Decisión 9). Separarlo partiría en dos algo que cambia junto. El fork de `linuxmint/cinnamon-spices-applets` no cuenta como segundo repositorio nuestro: es solo el escaparate, y lo que va allí lo fabrica `cinnamon/empaquetar.sh`.

Consecuencia: Spices solo instala lo que hay dentro de `files/<uuid>/`, así que el paquete lleva dentro una copia de `vaso.py` e `index.html`. Esa copia **se genera**, no se guarda en git (`dist/` está en `.gitignore`).

## Los umbrales

| Nivel | Desde | Consejo |
|---|---|---|
| `ok` | 0 % | Sigue |
| `watch` | 50 % | Compacta en el próximo corte natural |
| `compact` | 70 % | Compacta ya |
| `new` | 85 % | Sesión nueva o `/clear` |

Son criterio, no ciencia: están como constantes al principio de `vaso.py` para ajustarlos con el uso.

## Seguridad

Los transcripts contienen tus conversaciones y a veces fragmentos de código o datos privados. Tres barreras:

1. El servidor escucha solo en `127.0.0.1`: nadie de tu red puede entrar.
2. Comprueba la cabecera `Host` para frenar el DNS rebinding (ver glosario).
3. `/api/state` devuelve números, nunca el texto de tus mensajes. El texto solo sale de tu equipo si tú pulsas "Pedir consejo con IA", y la página lo avisa.
