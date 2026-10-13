# 01 · Setup: preparar el entorno

> Lo único que hace falta es Python y un navegador. No se instala ningún paquete.

## 1. Comprobar que tienes Python

Abre una terminal (en Windows: PowerShell; en Linux: tu terminal habitual) y escribe:

**Linux**
```bash
python3 --version
```

**Windows**
```powershell
python --version
```

Debe responder `Python 3.9` o superior. Si no:

- **Windows:** instálalo desde python.org o con `winget install Python.Python.3.12`. Marca "Add Python to PATH" en el instalador; sin eso, la terminal no encuentra el comando.
- **Linux (Debian/Ubuntu):** `sudo apt install python3`.

> 💡 **Nota para aprendices:** en Linux el comando es `python3` y en Windows `python`. Es el mismo programa; el nombre cambia por razones históricas (en Linux `python` fue durante años la versión 2).

## 2. Tener Claude Code con alguna sesión

El vaso lee las sesiones que Claude Code guarda en:

| Sistema | Carpeta |
|---|---|
| Linux | `/home/TU_USUARIO/.claude/projects/` |
| Windows | `C:\Users\TU_USUARIO\.claude\projects\` |

Si has usado Claude Code alguna vez, ya existe. No hay que configurar nada: el programa encuentra tu carpeta de usuario solo.

## 3. Arrancar

Dentro de la carpeta del proyecto:

```bash
python3 vaso.py
```

(En Windows, `python vaso.py`.) Se abre `http://127.0.0.1:8765` en tu navegador. Para pararlo: `Ctrl+C` en la terminal.

**Verificación:** ves el vaso con un porcentaje y el nombre de tu sesión más reciente.

## 4. Opciones

| Qué | Cómo |
|---|---|
| No abrir el navegador automáticamente | `python3 vaso.py --no-browser` |
| Usar otro puerto | variable de entorno `VASO_PORT` (ver abajo) |
| Sesiones en otra carpeta | variable de entorno `CLAUDE_CONFIG_DIR` |
| Comprobar que la lógica funciona | `python3 vaso.py --test` → imprime `ok` |

Cambiar el puerto:

```bash
VASO_PORT=9000 python3 vaso.py
```

```powershell
$env:VASO_PORT = 9000; python vaso.py
```

> ⚠️ **Errores comunes:** si cambias de puerto, el navegador lo trata como una página distinta y no verá la key que guardaste con el puerto anterior. Tendrás que pegarla otra vez.

## 5. (Opcional) Conseguir una API key gratuita

Solo si quieres el consejo con IA. Con una basta:

| Proveedor | Dónde se crea la key |
|---|---|
| Google Gemini | aistudio.google.com → "Get API key" |
| Groq | console.groq.com → "API Keys" |
| OpenRouter | openrouter.ai → "Keys" (usa modelos acabados en `:free`) |

Pégala en **Ajustes** dentro de la página. Los nombres de modelo gratuitos cambian con el tiempo: si el que viene por defecto da error, copia uno vigente de la web del proveedor en el campo "Modelo".
