#!/bin/bash

set -e

echo "Criando diretório ~/dep..."
mkdir -p ~/dep
cd ~/dep

echo "Baixando sshpass..."
wget -4 --no-check-certificate -c http://br.archive.ubuntu.com/ubuntu/pool/universe/s/sshpass/sshpass_1.09-1_amd64.deb

# 3. Instalar os pacotes com dpkg
echo "Instalando pacotes via dpkg... (Pode pedir sua senha)"

dpkg -i *.deb

# 5. Atualizar o cache de bibliotecas
echo "Atualizando cache de bibliotecas..."
ldconfig

echo "Instalação completa!"
