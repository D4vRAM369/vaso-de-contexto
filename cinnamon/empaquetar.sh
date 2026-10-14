#!/usr/bin/env bash
# Monta en dist/ la carpeta con la forma que pide linuxmint/cinnamon-spices-applets.
# Uso: cinnamon/empaquetar.sh   → luego copiar dist/<uuid> a la raíz del fork.
set -euo pipefail
cd "$(dirname "$0")/.."

UUID=vaso-contexto@d4vram
OUT="dist/$UUID"

rm -rf "$OUT"
mkdir -p "$OUT/files"
# Spices solo instala files/<uuid>/: lo que el applet necesita tiene que ir dentro.
# -L convierte el enlace simbólico vaso.py en una copia real del archivo.
cp -rL "cinnamon/$UUID" "$OUT/files/"
# El consejo con IA (BYOK) no va en el paquete: Spices no quiere applets que envíen datos
# del usuario a servicios externos. Se borran los bloques marcados byok:inicio … byok:fin.
for f in vaso.py index.html; do
    sed '/byok:inicio/,/byok:fin/d' "$f" > "$OUT/files/$UUID/$f"
done
if grep -rniE 'byok|urllib\.(request|error)|PROVIDERS|/api/advice|openrouter|api key' "$OUT/files"; then
    echo "ERROR: queda código del consejo con IA en el paquete" >&2
    exit 1
fi
cp cinnamon/README.md "$OUT/README.md"
echo '{"author": "D4vRAM369"}' > "$OUT/info.json"

if [ -f cinnamon/screenshot.png ]; then
    cp cinnamon/screenshot.png "$OUT/"
else
    echo "AVISO: falta cinnamon/screenshot.png (obligatoria para el pull request)" >&2
fi
echo "Listo: $OUT"
