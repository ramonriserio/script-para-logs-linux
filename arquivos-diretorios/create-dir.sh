#! /bin/bash

read -p "Digite o caminho do diretório a ser criado: " caminho
if [ -d $caminho ]; then
  echo "Diretório já existe."
else
  mkdir -p "$caminho"
  echo "Diretório criado com sucesso."
fi
