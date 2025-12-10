#!/bin/bash

# REQUIRE_FILE: guiConfigProj.zip

ARQUIVO_ZIP="/tmp/guiConfigProj.zip"

CAMINHO_BASE="/Zanthus/Zeus/pdvJava/pdvGUI"
PASTA_ALVO="$CAMINHO_BASE/guiConfigProj"

echo "[MODULO] Iniciando atualizacao GUI..."

if [ ! -f "$ARQUIVO_ZIP" ]; then
    echo "  ERRO CRITICO: ZIP nao encontrado em $ARQUIVO_ZIP"
    echo "  (Verifique se o nome no REQUIRE_FILE bate com o arquivo na pasta arquivos do host)"
    exit 1
fi

if [ -d "$PASTA_ALVO" ]; then
    DATA_HORA=$(date +%Y%m%d_%H%M%S)
    mv "$PASTA_ALVO" "${PASTA_ALVO}_${DATA_HORA}"
    echo "  [BACKUP] Pasta renomeada."
else
    echo "  [AVISO] Instalacao limpa."
fi

if command -v unzip &> /dev/null; then
    unzip -q -o "$ARQUIVO_ZIP" -d "$CAMINHO_BASE"
    echo "  [EXTRACAO] Sucesso (unzip)."
elif command -v jar &> /dev/null; then
    mkdir -p "$PASTA_ALVO"
    cd "$CAMINHO_BASE"
    jar xf "$ARQUIVO_ZIP"
    echo "  [EXTRACAO] Sucesso (jar)."
else
    echo "  ERRO: unzip nao encontrado."
    exit 1
fi

rm -f "$ARQUIVO_ZIP"
echo "  [LIMPEZA] ZIP removido de /tmp."