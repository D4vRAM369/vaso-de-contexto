# 07 · La clase: Vaso de contexto desde cero

> Versión "clase de ciclo formativo" (DAW/DAM). No hace falta saber programar. Se lee en paralelo a `03_PASO_A_PASO.md`: allí está el *cómo se hizo*; aquí, el *por qué importa*.

---

## Lección 1 — El problema: una memoria que no se ve

Imagina que cada vez que le hablas a un compañero, tuvieras que entregarle una carpeta con **todo** lo que os habéis dicho desde el principio, y él la leyera entera antes de contestar. La primera vez, una hoja. A la hora, un taco de doscientas.

Así funcionan los asistentes de IA. No recuerdan: releen. Esa carpeta se llama **contexto**, y tiene un grosor máximo.

Tres cosas pasan cuando engorda:

1. Tarda más y cuesta más.
2. Empieza a fijarse menos en las primeras hojas.
3. Si se llena, alguien tiene que tirar hojas o resumirlas.

Y lo peor: **no lo ves**. Escribes igual con la carpeta vacía que a punto de reventar.

**La idea del proyecto:** convertir ese número invisible en algo que se entiende de un vistazo. Un vaso de agua.

> 🧠 **Para pensar:** ¿por qué un vaso y no solo un número? Porque "147 000 de 200 000" hay que interpretarlo; un vaso casi lleno, no.

---

## Lección 2 — ¿Con qué se mide? Los tokens

Los modelos no cuentan letras ni palabras, sino **tokens**: trocitos de texto. "Casa" es un token; "extraordinariamente" son varios.

No hace falta saber partirlos. Basta con la idea: son los mililitros de nuestro vaso. Un vaso normal de Claude Code tiene 200 000; uno grande, 1 000 000.

---

## Lección 3 — Antes de construir, mirar si ya existe

Primera tentación: contar nosotros los tokens. Primera lección de oficio: **mira antes si alguien ya lo hace**.

Claude Code lleva un diario de cada conversación. En cada respuesta apunta cuántos tokens leyó el modelo. El dato exacto estaba ahí, esperando.

Ese diario es un archivo de texto donde cada renglón es una ficha con datos (formato **JSONL**). ¿Por qué un renglón por ficha? Porque para apuntar algo nuevo solo hay que añadir un renglón al final. Como un cuaderno de bitácora: nunca se reescribe, solo se continúa.

> 🧠 **Para pensar:** nuestro programa no le pregunta nada a Claude ni se mete en su funcionamiento. Solo lee su diario. Si nuestro programa se rompe, tu conversación ni se entera. Esa separación es una decisión de diseño, no una casualidad.

---

## Lección 4 — Dos piezas: la cocina y la sala

Un navegador web tiene prohibido abrir archivos de tu ordenador. Menos mal: si no, cualquier página podría leer tus documentos.

Pero nosotros necesitamos leer el diario. Solución: dos piezas.

- **La cocina (`vaso.py`)**: un programa en Python que sí puede leer tus archivos. Lee el diario, hace las cuentas y decide el consejo.
- **La sala (`index.html`)**: la página que ves. No cocina nada: pide el plato y lo presenta.

La sala le pregunta a la cocina cada 3 segundos "¿cómo va el vaso?". La cocina responde con unos cuantos números.

Este reparto tiene nombre en el oficio: **cliente–servidor**. La página es el cliente; el programa Python, el servidor. Casi toda la web funciona así. La diferencia es que aquí el servidor está en tu propio ordenador y no en internet.

**¿Por qué toda la inteligencia en la cocina?** Porque así hay un único sitio donde viven las reglas. Si mañana queremos el vaso en la terminal en vez de en una página, la cocina no cambia.

---

## Lección 5 — Sin instalar nada

Python trae de serie una caja de herramientas enorme, la **librería estándar**: leer archivos, montar un servidor web, hacer peticiones a internet. Este proyecto usa solo eso.

¿Por qué importa? Porque cada cosa que instalas es algo que puede fallar en otro ordenador. Al no instalar nada, el mismo archivo funciona en Linux y en Windows, hoy y dentro de tres años.

> 🧠 **Regla de oficio:** antes de añadir una pieza externa, pregúntate si lo que ya tienes lo resuelve.

---

## Lección 6 — Dibujar con texto

El vaso no es una foto. Es un **SVG**: instrucciones de dibujo escritas en texto ("línea de aquí a aquí, curva hasta allá").

El truco del agua: no se "rellena" el vaso. Hay un bloque grande de agua que siempre está ahí, y delante una plantilla con forma de vaso que solo deja ver lo de dentro. Como mirar un acuario por una ventana con forma de vaso. Para subir el nivel, se sube el bloque.

El movimiento suave no lo programamos fotograma a fotograma. Le decimos al navegador "cuando esto cambie de sitio, tarda 1,2 segundos en llegar" y él se encarga.

Y un detalle de respeto: hay personas a las que el movimiento constante en pantalla les marea, y lo indican en los ajustes de su sistema. La página lo consulta y, si es el caso, deja el agua quieta.

---

## Lección 7 — Reglas claras y comprobables

¿Cuándo avisar? Decidimos cuatro tramos:

| El vaso está… | Consejo |
|---|---|
| Por debajo de la mitad | Sigue |
| Entre 50 % y 70 % | Compacta cuando termines lo que estás haciendo |
| Entre 70 % y 85 % | Compacta ya |
| Por encima del 85 % | Empieza una conversación nueva |

Estos números no son verdades universales: son un criterio razonable. Por eso están escritos al principio del programa, con nombre propio, para cambiarlos sin buscar por todo el código.

Y los comprobamos con un **test**: un trocito de programa que dice "si el vaso está al 70 %, el consejo *tiene que ser* compactar; si no, grita". Ese test cazó un fallo real el primer día (está contado en `05_ERRORES_Y_SOLUCIONES.md`). Un programa pequeño con un test pequeño vale más que uno grande sin ninguno.

---

## Lección 8 — Pedir una segunda opinión: BYOK

Las reglas saben cuánta agua hay. No saben de qué estás hablando. Y la decisión fina (¿resumo o tiro todo?) depende de si has cambiado de tema.

Para eso, opcionalmente, le pedimos opinión a otro modelo de IA. ¿Quién paga? Nadie: varios servicios ofrecen un uso gratuito limitado si te registras y obtienes una **API key**, una especie de contraseña que te identifica.

A este modelo se le llama **BYOK** (*Bring Your Own Key*, "trae tu propia llave"). La aplicación no trae acceso incluido: tú pones tu llave.

Tres ideas importantes:

1. **Una key es un secreto.** Quien la tenga gasta tu cuota. Por eso se guarda en tu navegador y no en un archivo del proyecto, que podría acabar publicado.
2. **Sin key, todo funciona igual.** La IA es un extra, no un requisito.
3. **Transparencia.** Para opinar, el modelo necesita leer tus últimos mensajes, y eso significa enviarlos a una empresa externa. La página lo dice claramente, y solo ocurre cuando pulsas el botón.

---

## Lección 9 — "Está en mi ordenador" no significa "está protegido"

Tus conversaciones pueden contener cosas privadas. Dos precauciones, cada una de una línea:

- **Escuchar solo dentro de casa.** El servidor atiende únicamente a tu propio ordenador. Si atendiera a toda la red, cualquiera en la misma wifi podría leer tus sesiones.
- **Comprobar quién llama.** Existe un truco por el que una web maliciosa puede hacer que tu navegador hable con programas locales. El servidor comprueba a qué nombre iba dirigida la llamada y, si no es el suyo, la rechaza.

> 🧠 **Para pensar:** la seguridad rara vez es una gran muralla. Suele ser una suma de comprobaciones pequeñas en los sitios donde entra información desde fuera.

---

## Repaso

| Idea | En una frase |
|---|---|
| Contexto | La carpeta que el modelo relee en cada mensaje |
| Token | La unidad en que se mide |
| JSONL | Un diario: una ficha por renglón |
| Cliente–servidor | La sala pide, la cocina prepara |
| Librería estándar | Lo que ya viene con Python |
| SVG | Dibujos escritos como texto |
| Test | Un programa que vigila a otro |
| BYOK | Tú pones la llave |

## Preguntas de autoevaluación

1. ¿Por qué un "sí" al final de una conversación larga cuesta más que al principio?
2. ¿Por qué la página no lee directamente el archivo de la sesión?
3. ¿Qué diferencia hay entre `/compact` y `/clear`, y cuándo usarías cada uno?
4. ¿Por qué la API key no se guarda en un archivo del proyecto?
5. Si quisieras el mismo aviso en la terminal, ¿qué archivo reutilizarías tal cual?
