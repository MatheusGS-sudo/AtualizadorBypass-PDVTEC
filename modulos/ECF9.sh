#!/bin/bash

echo "[MÓDULO] Verificando ECF9A.CFG..."
ARQUIVO="/Zanthus/Zeus/pdvJava/ECF9A.CFG"

if [ ! -f "$ARQUIVO" ]; then
    touch "$ARQUIVO"
fi

# Função interna do módulo
atualizar_linha() {
    local FILE="$1"
    local KEY="$2"
    local LINE="$3"
    if grep -q "^${KEY}=" "$FILE"; then
        sed -i "s|^${KEY}=.*$|${LINE}|" "$FILE"
    else
        echo "$LINE" >> "$FILE"
    fi
}

atualizar_linha "$ARQUIVO" "tecla:121" "tecla:121=30  # Tecla y     VENDEDOR"
atualizar_linha "$ARQUIVO" "tecla:89"  "tecla:89=30   # Tecla y     VENDEDOR"
atualizar_linha "$ARQUIVO" "tecla:231" "tecla:231=64  # Tecla ç     CONSULTA MERCADORIA POR DESCRICAO"
atualizar_linha "$ARQUIVO" "tecla:199" "tecla:199=64  # Tecla Ç     CONSULTA MERCADORIA POR DESCRICAO"

echo "  [OK] ECF9A configurado."