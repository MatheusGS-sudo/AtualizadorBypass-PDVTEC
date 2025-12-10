#!/bin/bash

echo "[MÓDULO] Verificando CliSiTef.ini..."
ARQUIVO="/Zanthus/Zeus/pdvJava/CliSiTef.ini"
CHAVE_COMPLETA="IdentificaMensagens=1"
CHAVE_BUSCA="IdentificaMensagens="
SECAO_REGEX="^\[Geral\]"

if [ ! -f "$ARQUIVO" ]; then
    echo "  AVISO: Arquivo $ARQUIVO não encontrado."
    exit 0
fi

sed -i.bak 's/\r$//' "$ARQUIVO"

if grep -q "^${CHAVE_BUSCA}" "$ARQUIVO"; then
    echo "  AÇÃO: Atualizando chave existente..."
    sed -i "s|^${CHAVE_BUSCA}.*$|${CHAVE_COMPLETA}|" "$ARQUIVO"
else
    echo "  AÇÃO: Criando chave nova..."
    sed -i "/$SECAO_REGEX/s/.*/&\n$CHAVE_COMPLETA/" "$ARQUIVO"
fi
echo "  [OK] CliSiTef configurado."