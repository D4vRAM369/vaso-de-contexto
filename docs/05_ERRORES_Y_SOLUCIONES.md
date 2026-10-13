# 05 · Errores y soluciones

> Errores reales, tal como ocurrieron.

## Error: el crecimiento por turno salía siempre 0

**Fecha:** 13/10/2026
**Contexto:** Primera ejecución de `python3 vaso.py --test`, recién escrito `parse()`.

**El error exacto:**
```
AssertionError: {... 'used': 3100, 'turns': 2, 'growth': 0, 'history': [1000, 3000], ...}
```

El test tenía dos turnos, de 1000 y 3000 tokens. El crecimiento esperado era 2000 y salió 0.

**Por qué ocurrió:**

Para calcular cuánto crece el contexto hay que emparejar cada turno con el siguiente. La línea era:

```python
ups = [b - a for a, b in zip(ctxs[-11:], ctxs[-10:]) if b > a]
```

La idea: "los últimos 11" emparejados con "los últimos 10" dan parejas desplazadas una posición. Eso solo es cierto si la lista tiene **11 o más** elementos. Con 2 elementos, `ctxs[-11:]` y `ctxs[-10:]` devuelven lo mismo, la lista entera, porque Python no se queja cuando pides más elementos de los que hay. Resultado: cada turno emparejado consigo mismo, diferencia 0.

**Cómo se resolvió:**

Primero se recorta, luego se desplaza:

```python
recent = ctxs[-11:]
ups = [b - a for a, b in zip(recent, recent[1:]) if b > a]
```

`recent[1:]` es "la misma lista sin el primero", y eso siempre queda desplazado, tenga el tamaño que tenga.

**Qué aprendimos:**

- Los cortes de lista (*slices*) en Python nunca dan error por pasarse de largo. Es cómodo y a la vez esconde fallos: el código funcionaba con sesiones largas y fallaba en silencio con las cortas.
- El fallo lo cazó un test de 2 turnos. Los casos pequeños (lista vacía, un elemento, dos) son donde más se rompe el código, y los más baratos de probar.
- Sin el test, la página habría mostrado "+0 por turno" en sesiones recién empezadas y nadie habría sospechado.

---

## Error: el primer commit incluyó archivos que no eran del proyecto

**Fecha:** 13/10/2026
**Contexto:** `git init` seguido de `git add -A` y `git commit`.

**El síntoma:**
```
A  .omc/state/agent-replay-62b6d587-….jsonl
A  .omc/state/last-tool-error.json
```

**Por qué ocurrió:** `git add -A` significa "añade todo lo que haya en la carpeta". Una herramienta instalada en el equipo (oh-my-claudecode) había creado su carpeta de estado `.omc/` dentro del proyecto, y entró en el commit.

**Cómo se resolvió:** Se añadió `.omc/` a `.gitignore`, se sacó del índice con `git rm -r --cached .omc` (lo quita de git sin borrarlo del disco) y se rehízo el commit con `git commit --amend`.

**Qué aprendimos:**
- Lee siempre la lista de `git status` antes de confirmar un commit. El fallo estaba a la vista.
- `--amend` reescribe el último commit. Es seguro mientras no lo hayas subido a ningún sitio; después, ya no.
- Si en vez de un archivo de estado hubiera sido una API key, sacarla del historial ya publicado es mucho más difícil. El `.gitignore` se escribe antes del primer `add`.

---

## Error: `grep: contador máximo no válido`

**Fecha:** 13/10/2026
**Contexto:** Explorando los transcripts desde la terminal con `grep … | head -1`.

**El error exacto:**
```
grep: contador máximo no válido
```

**Por qué ocurrió:** En este equipo hay una herramienta (RTK) que reescribe los comandos de terminal para ahorrar tokens. Su traducción de esa tubería le pasó a `grep` un argumento que no entendía.

**Cómo se resolvió:** Se hizo la misma búsqueda con un script corto de Python, que no pasa por esa reescritura.

**Qué aprendimos:** Cuando un comando correcto falla de forma rara, mira qué hay *entre* tú y el comando (alias, envoltorios, hooks). Y tener una segunda vía para la misma tarea desbloquea rápido.

---
