#!/bin/bash

echo "[MÓDULO] Configurando arquivos RESTG..."
DIR_PDV="/Zanthus/Zeus/pdvJava"
ARQ1="$DIR_PDV/RESTG0261.CFG"
ARQ4="$DIR_PDV/RESTG0000.CFG"

cat > "$ARQ1" << 'EOF'
endereco=geocosmeticos.zanthusonline.com.br
path=/manager/restfull/pdv/comunicacao_pdv.php5
timeout=30
opcoes=63
SSL=1
FLAGS=1
EOF

cp "$ARQ1" "$DIR_PDV/RESTG0262.CFG"
cp "$ARQ1" "$DIR_PDV/RESTG0263.CFG"
chmod +x "$DIR_PDV"/RESTG026*.CFG

if [ -f "$ARQ4" ]; then
    sed -i.bak 's/^\s*timeout\s*=\s*30\s*$/timeout=5/' "$ARQ4"
fi
echo "  [OK] RESTG configurados."