#!/bin/bash

DIR_MODULOS="./modulos"
DIR_ARQUIVOS="./arquivos"
ARQUIVO_IPS="ips.txt"
SCRIPT_DEP="instaladorpass.sh"

if ! command -v sshpass &> /dev/null; then
    echo "ERRO: Instale o 'sshpass' na SUA maquina"
    exit 1
fi

echo "=== AUTENTICACAO ==="
read -p "Usuario SSH (para todas as maquinas): " USUARIO
read -rs -p "Senha (sudo): " SENHA
echo ""
export SSHPASS="$SENHA"
SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=10"

# --- INSTALAÇÃO DE DEPENDÊNCIAS (BYPASS) ---
echo ""
echo "=== PREPARACAO DE AMBIENTE ==="
read -p "Deseja instalar as dependencias ($SCRIPT_DEP) nas maquinas antes de prosseguir? (s/n): " OP_DEP

if [[ "$OP_DEP" == "s" || "$OP_DEP" == "S" ]]; then
    if [ ! -f "$SCRIPT_DEP" ]; then
        echo "ERRO: O arquivo '$SCRIPT_DEP' nao foi encontrado na pasta atual."
        exit 1
    fi

    echo "Quais IPs deseja usar?"
    echo "1) Usar a lista padrao ($ARQUIVO_IPS)"
    echo "2) Digitar IPs manualmente (apenas para essa instalacao)"
    read -p "Opcao: " OP_IP

    if [ "$OP_IP" == "2" ]; then
        read -p "Digite os IPs separados por espaco: " IPS_MANUAIS
        LISTA_PROCESSAMENTO=$IPS_MANUAIS
    else
        if [ ! -f "$ARQUIVO_IPS" ]; then
             echo "ERRO: Arquivo $ARQUIVO_IPS nao encontrado."
             exit 1
        fi
        LISTA_PROCESSAMENTO=$(grep -vE "^\s*#|^\s*$" "$ARQUIVO_IPS")
    fi

    echo ""
    echo "Iniciando instalacao do '$SCRIPT_DEP' nas maquinas..."

    for ip in $LISTA_PROCESSAMENTO; do
        echo " -> Processando instalacao em: $ip"
        { echo "$SENHA"; cat "$SCRIPT_DEP"; } | sshpass -e ssh $SSH_OPTS "${USUARIO}@${ip}" "sudo -S bash"
    done
    echo "--- Fim da etapa de instalacao ---"
    echo ""
fi

echo "=== SELECIONE O MODULO PARA EXECUTAR ==="
files=("$DIR_MODULOS"/*.sh)
if [ ${#files[@]} -eq 0 ]; then
    echo "Nenhum modulo encontrado em $DIR_MODULOS"
    exit 1
fi

PS3="Digite o numero do modulo (ou Ctrl+C para sair): "
select MODULO_PATH in "${files[@]}"; do
    if [ -n "$MODULO_PATH" ]; then
        echo "Voce escolheu: $MODULO_PATH"
        break
    else
        echo "Opcao invalida."
    fi
done

ARQUIVO_EXTRA=$(grep "^# REQUIRE_FILE:" "$MODULO_PATH" | cut -d: -f2 | xargs)

if [ -n "$ARQUIVO_EXTRA" ]; then
    CAMINHO_LOCAL_EXTRA="$DIR_ARQUIVOS/$ARQUIVO_EXTRA"
    echo " -> Este modulo requer o arquivo: $ARQUIVO_EXTRA"

    if [ ! -f "$CAMINHO_LOCAL_EXTRA" ]; then
        echo "ERRO: O arquivo '$ARQUIVO_EXTRA' nao esta na pasta '$DIR_ARQUIVOS'."
        exit 1
    fi
else
    echo " -> Este modulo nao requer envio de arquivos."
fi

echo ""
echo "Iniciando execucao do modulo..."


total_pdvs=0
sucesso_pdvs=0
falha_pdvs=0
ips_falha=()

while IFS= read -r ip || [[ -n "$ip" ]]; do
    [[ -z "$ip" || "$ip" =~ ^# ]] && continue

    ((total_pdvs++))
    echo ""
    echo "--------------------------------------------------"
    echo "Processando Modulo em: $ip ($total_pdvs)"

    if [ -n "$ARQUIVO_EXTRA" ]; then
        echo "   [...] Enviando $ARQUIVO_EXTRA para /tmp..."
        sshpass -e scp $SSH_OPTS "$CAMINHO_LOCAL_EXTRA" "${USUARIO}@${ip}:/tmp/$ARQUIVO_EXTRA"

        if [ $? -ne 0 ]; then
            echo "   [ERRO CRITICO] Falha no upload SCP. Pulando maquina."
            ((falha_pdvs++))
            ips_falha+=("$ip (Erro Upload)")
            continue
        fi
        echo "   [OK] Upload concluido."
    fi

    echo "   [...] Executando script remoto..."
    { echo "$SENHA"; cat "$MODULO_PATH"; } | sshpass -e ssh $SSH_OPTS "${USUARIO}@${ip}" "sudo -S bash"

    if [ $? -eq 0 ]; then
        echo "   [SUCESSO] Modulo executado em $ip"
        ((sucesso_pdvs++))
    else
        echo "   [FALHA] Erro na execucao remota em $ip"
        ((falha_pdvs++))
        ips_falha+=("$ip (Erro Script)")
    fi

done < "$ARQUIVO_IPS"

unset SSHPASS

echo ""
echo "=================================================="
echo "                  RESUMO FINAL                    "
echo "PDVs processados: $total_pdvs | Sucesso: $sucesso_pdvs | Falha: $falha_pdvs"
if [ $falha_pdvs -gt 0 ]; then
    echo "--------------------------------------------------"
    echo "IPs com erro:"
    printf "  - %s\n" "${ips_falha[@]}"
fi
echo "=================================================="