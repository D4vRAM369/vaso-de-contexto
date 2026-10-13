# 04 · Conceptos aprendidos

## 1. El modelo no tiene memoria: se le reenvía todo

Es la idea que explica el proyecto entero. Un modelo de IA no "recuerda" tu conversación. En cada mensaje, el programa (Claude Code) le manda **toda la conversación otra vez** y el modelo la lee de cero.

De ahí salen tres consecuencias:

- Cada mensaje es más caro y lento que el anterior, aunque escribas solo "sí".
- Hay un máximo: lo que no cabe, se pierde.
- Mucho antes de llenarse, el modelo ya atiende peor a lo antiguo. Un vaso al 80 % no falla, pero rinde menos.

**Conexión con algo conocido:** es como explicarle un problema a alguien releyéndole cada vez todo el hilo de correos desde el primero.

## 2. Compactar, limpiar o empezar de cero

| Acción | Qué conserva | Cuándo |
|---|---|---|
| `/compact` | Un resumen | Sigues con la misma tarea y el vaso va alto |
| `/clear` | Nada | Cambias de tema |
| Sesión nueva | Nada (lo que tú le pegues) | El vaso está casi lleno o ya se compactó varias veces |

Truco: `/compact` acepta instrucciones. `/compact conserva las decisiones de arquitectura y lo pendiente` da un resumen mucho mejor que dejarlo a su criterio.

## 3. La caché cambia cuándo conviene actuar

Mientras escribes seguido, releer la conversación cuesta poco porque está en caché. Tras un rato largo sin actividad, la caché caduca y el siguiente mensaje se paga entero.

Conclusión práctica: si vuelves de comer y el vaso va por la mitad, compactar **antes** de escribir te ahorra pagar la relectura completa de algo que ibas a resumir igual.

## 4. Leer el dato en vez de calcularlo

Íbamos a estimar tokens. Resultó que Claude Code ya los apuntaba. Antes de construir un medidor, busca si el sistema ya mide.

## 5. Separar "pensar" de "pintar"

`vaso.py` decide; `index.html` dibuja. Se puede cambiar el vaso por una barra, o por un texto en la terminal, sin tocar una sola regla. Y las reglas se prueban sin abrir un navegador.

## 6. Programar a la defensiva con datos ajenos

El formato del transcript no es nuestro. Tres hábitos:

- `d.get("campo")` en lugar de `d["campo"]`.
- `try/except` alrededor de cada línea: una línea rota no tira el programa.
- Ignorar lo que no reconoces en vez de fallar.

## 7. Una forma grande, recortada

El agua no se "rellena": es un bloque que siempre existe, visto a través de una ventana con forma de vaso. Mover es más fácil que redibujar. El mismo truco sirve para barras de progreso, termómetros o depósitos.

## 8. Un formato común vale más que tres integraciones

Tres proveedores, una función, porque los tres hablan el mismo "idioma" de petición. Cuando eliges servicios, que compartan formato te ahorra código y te deja cambiar de uno a otro sin reescribir.

## 9. Local no significa seguro por defecto

Un servidor en tu máquina puede ser alcanzado por otros equipos de la red (si escucha en `0.0.0.0`) o por webs que visitas (DNS rebinding). Dos líneas de código cierran ambas puertas.
