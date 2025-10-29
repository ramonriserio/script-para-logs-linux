#! /bin/bash

read -p "Digite o caminho do diretório que será 'backupeado': " caminho
if [ -d $caminho ]; then
  tar -czf backup.tar.gz "$caminho"
else
  echo "O caminho não é um diretório válido ou ele não existe."
fi
