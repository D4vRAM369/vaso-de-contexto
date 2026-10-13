# Vaso de contexto

> Un vaso de agua digital que se llena a medida que tu conversación con Claude Code ocupa memoria, y te avisa de cuándo conviene vaciarlo.

## ¿Qué es esto?

Cuando hablas con un modelo de IA, todo lo dicho hasta ese momento (tus mensajes, sus respuestas, los archivos que leyó) viaja con cada mensaje nuevo. Esa "mochila" se llama **contexto** y tiene un tamaño máximo. Si se llena, el modelo empieza a olvidar o a resumir por su cuenta, y cada mensaje sale más caro y más lento.

El problema es que ese llenado es invisible. Este proyecto lo hace visible: una página en tu navegador con un vaso que sube de nivel, barras con los datos clave y un consejo claro (seguir, compactar, limpiar o empezar de cero). Opcionalmente, con una API key gratuita, un modelo de IA mira tus últimos mensajes y te da un consejo a medida.

Funciona igual en Linux y en Windows y no instala nada: solo necesita Python.

## ¿Qué vas a aprender siguiendo esta documentación?

- Qué son los tokens y la ventana de contexto, y por qué importan
- Cómo leer archivos JSONL línea a línea con Python
- Cómo montar un servidor web mínimo sin instalar nada
- Cómo dibujar y animar un gráfico con SVG y CSS
- Cómo una página pide datos a un servidor (`fetch`) y se refresca sola
- Qué es BYOK y cómo llamar a una API de IA con tu propia key
- Tres medidas de seguridad básicas para una herramienta local

## Stack tecnológico

| Tecnología | Versión | Para qué se usa |
|---|---|---|
| Python | 3.9 o superior (probado en 3.12) | Servidor local y lectura de las sesiones |
| HTML + CSS + JavaScript | Sin frameworks | La página con el vaso |
| SVG | — | El dibujo del vaso y el agua |
| APIs de Gemini / Groq / OpenRouter | Formato "chat completions" | Consejo opcional con IA |

## Estructura del proyecto

```
Vaso de contexto/
├── vaso.py        ← el servidor: lee, calcula y aconseja
├── index.html     ← la página: dibuja lo que el servidor le dice
├── CLAUDE.md      ← guía para Claude Code al trabajar en este repo
└── docs/          ← esta documentación
```

## Cómo seguir esta documentación

Si nunca has programado, empieza por `07_DAW_DAM_CLASE.md`. Si quieres reproducir el proyecto: 01 → 02 → 03. El glosario (`00`) está para consultarlo cuando un término no te suene.

---
*Documentado usando metodología PBL. Creado por Brian (D4vRAM) con Claude.*
