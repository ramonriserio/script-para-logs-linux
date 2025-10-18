# Criando _script_ para processamento de arquivos de logs no Linux

<img width="720" height="338" alt="image" src="https://github.com/user-attachments/assets/1c97946d-8b7e-4d92-8273-c2a93b8368ce" />

Este conteúdo abordará práticas essenciais para a automação e manipulação de  _logs_ no Linux, desde a criação inicial de _scripts bash_ e configuração de permissões, passando por busca e filtragem de informações em diretórios e arquivos, até técnicas para ordenar dados, eliminar duplicatas e comparar conteúdos. Também serão vistos formas para extrair valores numéricos de arquivos com fins analíticos, compactação de arquivos e agendamento de tarefas utilizando o _cron_.

## 1. Configuração inicial do _script_
Inicie o _script bash_ criando um arquivo chamado `monitoramento-logs.sh` e, no arquivo, crie uma variável que armazena o caminho para o diretório em que os arquivos de  _logs_ estão armazenados. Em seguida faça o _script_ exibir uma mensagem na tela, conforme mostrado a seguir:

```
#!/bin/bash
LOG_DIR=”../myapp/logs”
echo “Verificando os  _logs_ no diretorio $LOG_DIR”
```

## 2. Gerenciando as permissões de arquivos
Dê a permissão de execução para o _script_, rodando o comando:

```
chmod 755 monitoramento-logs.sh
```
Em seguida, execute o _script_ com o comando abaixo e verifique o resultado:

```
./monitoramento-logs.sh
```
No terminal, execute o comando a seguir para criar um novo usuário chamado julia:

```
sudo adduser julia
```
Serão pedidas algumas informações. Informe uma senha para esse usuário. As demais informações são opcionais.

Verifique se o usuário foi criado com sucesso, listando os usuários do sistema, com o comando:

```
cat /etc/passwd
```
Isso mostrará o novo usuário na lista.

Crie um novo grupo com o comando:

```
sudo groupadd devs
```
Verifique se o novo grupo foi criado com sucesso com o comando:

```
getent group devs
```
Adicione o novo usuário julia ao grupo devs usando o comando:

```
sudo usermod -aG devs julia
```
Verifique se o usuário foi adicionado com sucesso, rodando o comando:

```
getent group devs
```
Vá para o diretório home do seu usuário e altere o grupo para devs:

```
sudo chown -R :devs /home/SEU-USUARIO
```
Lembre-se de substituir `SEU-USUARIO`, pelo nome do seu usuário no seu sistema Linux.

Para verificar se a alteração de grupo deu certo, rode o comando:

```
ls -ld
```
Altere para o usuário julia, usando o comando:

```
su - julia
```
Informe a senha que você utilizou para criar esse usuário.

Entre na pasta do _script_ com o comando:

```
cd /home/SEU-USUARIO/scripts-linux
```
Lembre-se de substituir `SEU-USUARIO`, pelo nome do seu usuário no seu sistema Linux.

Execute o _script_ com o comando:

```
./processamento-logs.sh
```
Para voltar para o seu usuário basta rodar o comando:

```
su - SEU-USUARIO
```
Substitua `SEU-USUARIO` pelo nome do seu usuário no seu sistema Linux.

## 3. Fazendo busca e usando filtros em  _logs_
Agora vamos testar e incorporar os comandos `find`, `grep` e `sed` no _script_ de monitoramento de  _logs_.

Utilizaremos o comando find para localizar arquivos com extensão .log e integrá-lo a um laço while no _script_, permitindo percorrer cada arquivo encontrado. Dentro do laço, aplicaremos o comando `grep` para filtrar linhas contendo as strings ERROR e SENSITIVE_DATA, salvando os resultados com os operadores de redirecionamento `>` e `>>`. Em seguida, usaremos o comando `sed` para substituir informações sensíveis, como senhas e tokens, ocultando esses dados.

Em seu diretório home, execute o comando a seguir:

```
find myapp/logs/ -name “*.log”
```
Esse comando exibirá no terminal o nome de todos os arquivos que terminam com a extensão _.log_.

Em seguida, vá para a pasta do _script_ com os comandos:

```
cd 
cd _script_s-linux
```
Abra o _script_ num editor de texto e adicione o comando `find` utilizado anteriormente. Altere o caminho da pasta pela variável que armazena o caminho para esse diretório:

```
find $LOG_DIR -name “*.log”
```
No _script_, redirecione a saída desse comando para um laço de repetição `while`. Esse laço deve definir o IFS (separador de campo interno) como vazio, além de ler e salvar cada entrada do comando anterior em uma variável chamada arquivo.

O IFS determina como o _shell_ divide uma string em partes. Por padrão, ele considera espaço, tabulação e quebra de linha como separadores. Isso é útil, por exemplo, ao ler linhas de um arquivo ou processar a saída de um comando.

Lembre-se de adicionar a opção -print0 no comando `find`, para que o delimitador `\0` seja utilizado. Adicione um `echo` dentro do laço de repetição para exibir o nome dos arquivos encontrados:

```
find $LOG_DIR -name “*.log” -print0 | while IFS= read -r -d ‘’ arquivo; do:
  echo ‘’Arquivo encontrado: $arquivo’’
done
```
Salve e feche o _script_ e execute-o com o comando:

```
./processamento-logs.sh
```
Ele deverá exibir o nome dos arquivos encontrados!

Em seguida, vá para a pasta dos  _logs_:

```
cd
cd myapp/logs
```
Utilize o comando grep para filtrar as linhas de erro de um dos arquivos de _log_, com o comando:

```
grep “ERROR” myapp-backend.log
```
A saída exibirá apenas as linhas com a palavra ERROR.

Use o operador de redirecionamento `>` para salvar a saída desse comando em um arquivo chamado `logs-erro`:

```
grep “ERROR” myapp-backend.log `>` logs-erro
```
Verifique se o conteúdo foi salvo no arquivo, com o comando:

```
cat logs-erro
```
Vá para a pasta do _script_:

```
cd
cd _script_s-linux
```
Abra o _script_ com um editor de texto, apague a linha do comando `echo` dentro do laço de repetição e adicione em seu lugar o comando grep utilizado anteriormente.

Substitua o nome do arquivo pela variável arquivo e altere o arquivo `log-erro` pelo próprio nome do arquivo de _log_ seguido por `.filtrado` para auxiliar na organização:

```
grep “ERROR” “$arquivo” > “${arquivo}.filtrado”
```
Salve o _script_ e execute-o no terminal.

Vá na pasta de  _logs_ e veja que os arquivos finalizados em `.filtrado` foram criados.
Depois volte para o _script_ e adicione um novo `grep` que filtra linhas com a _string_ SENSITIVE-DATA e utilize o operador de redirecionamento `>>`:

```
grep “SENSITIVE_DATA” “$arquivo” >> “${arquivo}.filtrado”
```
Salve o _script_ e vá para a pasta de _logs_.

Utilize no terminal o comando `sed` para substituir informações sensíveis em um arquivo `.filtrado`:

```
sed ‘s/User password is .*/User password is REDACTED/g’ myapp-backend.log.filtrado
```
Veja que a saída agora oculta a senha do usuário.

Vá para o _script_ e adicione o comando sed com a opção `-i`. Essa opção fará com que o comando salve as alterações no arquivo:

```
sed -i ‘s/User password is .*/User password is REDACTED/g’ “${arquivo}.filtrado”
```
Adicione também outras linhas do comando sed para ocultar informações como tokens, chave de API e dígitos de cartão de crédito:

```
sed -i ‘s/User password reset request with token .*/User password reset request with token REDACTED/g’ “${arquivo}.filtrado”
sed -i ‘s/API key leaked: .*/API key leaked: REDACTED/g’ “${arquivo}.filtrado”
sed -i ‘s/User credit card last four digits: .*/User credit card last four digits: REDACTED/g’ “${arquivo}.filtrado”
sed -i ‘s/User session initiated with token: .*/User session initiated with token: REDACTED/g’ “${arquivo}.filtrado”
```
Salve o _script_ e execute-o. Depois volte para a pasta de _logs_ e dê um `cat` em um dos arquivos com final `.filtrado` para verificar as alterações:

```
cat myapp-backend.log.filtrado
```

## 4. Ordenando, filtrando e analisando logs
Agora utilizaremos o comando sort para ordenar linhas de arquivos de _log_ por data, o comando `uniq` para remover duplicatas e gerar arquivos sem repetições, e o comando `diff` para comparar diferenças entre arquivos.

Testaremos esses comandos no terminal e os incorporaremos ao _script_ de monitoramento, aprimorando sua funcionalidade com ordenação, filtragem e análise comparativa dos arquivos gerados.

Vá para a pasta com os arquivos de  _logs_:

```
cd myapp/logs
```
Utilize o comando `sort` no terminal para ordenar os _logs_ de um arquivo `.filtrado` de acordo com a data:

```
sort myapp-backend.log.filtrado
```
Teste a opção `-r` para ordenar o arquivo de forma decrescente:

```
sort -r myapp-backend.log.filtrado
```
Como o `sort` não salva a ordenação diretamente no arquivo, podemos usar a opção `-o` para salvar sua saída em um arquivo chamado `logs-ordenados`:

```
sort myapp-backend.log.filtrado -o logs-ordenados
```
Vá para o _script_ de monitoramento de _logs_ e adicione o comando `sort`. Lembre-se de alterar o comando no _script_ com as variáveis adequadas:

```
sort “${arquivo}.filtrado” -o “${arquivo}.filtrado”
```
Salve o _script_ e execute-o.

Abra a pasta de _logs_ e veja que agora os arquivos de _logs_ estão ordenados:

```
cat myapp-backend.log.filtrado
```
Na pasta de _logs_, use o comando `uniq` para remover as linhas duplicadas de um arquivo `.filtrado`:

```
uniq myapp-backend.log.filtrado
```
A saída desse comando mostra os _logs_ filtrados sem duplicatas.

Para salvar a saída desse comando em um arquivo chamado `logs-sem-duplicatas`, utilize um operador de redirecionamento, como o `>`:

```
uniq myapp-backend.log.filtrado > logs-sem-duplicatas
```
Abra o _script_ e adicione o comando `uniq` dentro do laço de repetição. Substitua os nomes dos arquivos pelas devidas variáveis, criando um arquivo com o final `.unico` que salvará a saída do comando:

```
uniq “${arquivo}.filtrado” > “${arquivo}.unico”
```
Salve o _script_ e execute-o.

Na pasta de _logs_, verifique a criação dos arquivos `.unico` e seu conteúdo:

```
cat myapp-backend.log.unico
```
Ainda na pasta de _logs_, utilize o comando `diff` para analisar as diferenças entre dois arquivos:

```
diff myapp-backend.log myapp-backend.log.unico
```
Lembre-se que a sintaxe da saída desse comando mostra algumas informações.

As letras indicam quais operações foram aplicadas, podendo ser:

- d: Linha deletada no arquivo original
- c: Linha alterada (com mudanças);
- a: Linha adicionada no arquivo modificado.

Os números indicam as linhas nos arquivos.
Experimente também utilizar o `diff` para comparar um arquivo com ele mesmo. Assim, a saída será nula, indicando que não há nenhuma diferença entre os arquivos:

```
diff myapp-backend.log myapp-backend.log
```

## 5. Analisando informações de logs
Agora aprenderemos a extrair dados quantitativos de arquivos com o comando `wc`, armazenar essas informações em variáveis e registrá-las em um arquivo estatístico. Também concatenaremos múltiplos arquivos .unico em um único arquivo combinado com `cat`, refatoraremos nomes usando `sed`, e criaremos um diretório específico para armazenar os _logs_ processados. Utilizaremos estruturas condicionais `if` para adicionar tags de origem às linhas dos _logs_ combinados, como [FRONTEND] e [BACKEND], e finalizaremos ordenando o arquivo pela data presente na segunda coluna. Depois incorporaremos esses comandos ao _script_ de monitoramento.

No terminal, na pasta dos arquivos de  _logs_, rode o comando a seguir para obter a quantidade de linhas de um dos arquivos de  _logs_ com final `.unico`:

```
wc -l myapp-backend.log.unico
```
Na sequência, para obter a quantidade de palavras de um dos arquivos de  _logs_ com final `.unico` rode no terminal o comando abaixo :

```
wc -w myapp-backend.log.unico
```
Utilize o operador de redirecionamento `<` para redirecionar o conteúdo de um dos arquivos de  _logs_ com final `.unico` para o comando `wc`. Obtendo assim somente o número de linhas e em seguida o número de palavras, sem o nome do arquivo na saída:

```
wc -w < myapp-backend.log.unico
wc -l < myapp-backend.log.unico
```
Vá para a pasta do _script_, abra o _script_ e adicione os comandos acima dentro do laço de repetição, alterando o nome do arquivo pela variável correspondente:

```
wc -w < “${arquivo}.unico”
wc -l < “${arquivo}.unico”
```
Crie variáveis que armazenem os valores de saída desses comandos:

```
num_linhas=$(wc -l < “${arquivo}.unico”)
num_palavras=$(wc -w < “${arquivo}.unico”)
```
Utilize o comando `echo` em conjunto com o operador de redirecionamento `>>` para armazenar esses valores em um arquivo chamado `log_stats.txt`:

```
echo “Arquivo: ${arquivo}.unico” >> log_stats.txt
echo “Número de linhas: $num_linhas” >> log_stats.txt 
echo “Número de palavras: $num_palavras” >> log_stats.txt 
echo “ — — — — — — — — — — — — — — -” >> log_stats.txt
```
Salve o _script_ e execute-o.

Na pasta do _script_, verifique o conteúdo do arquivo gerado com o comando abaixo:

```
cat log_stats.txt
```
Abra novamente o _script_, e crie uma variável que salve somente o nome dos arquivos de  _logs_ processados com final `.unico`, sem o diretório, utilizando o comando basename:

```
nome_arquivo=$(basename “${arquivo}.unico”)
```
Altere a linha que contém o `echo` que salva o nome do arquivo, para utilizar o valor da variável criada:

```
echo “Arquivo: $nome_arquivo” >> log_stats.txt
```
Salve o _script_.

No terminal, apague o arquivo `log-stats.txt` para termos um arquivo novo com as devidas alterações.

```
rm log_stats.txt
```
Rode o _script_ e verifique novamente o conteúdo do arquivo `log_stats.txt`.

Abra novamente o _script_, e antes do laço de repetição, crie uma variável que armazena o caminho para um diretório chamado `logs-processados`. Também adicione o comando mkdir para criar esse diretório caso ele não exista:

```
ARQUIVO_DIR=”../myapp/logs-processados”

mkdir -p $ARQUIVO_DIR
```
Utilize o comando `cat` em conjunto com o operador de redirecionamento `>>` para salvar as informações de cada arquivo de _logs_ processados em um arquivo final na pasta criada. Para isso, adicione o trecho a seguir dentro do laço de repetição:

```
cat “${arquivo}.unico” >> “${ARQUIVO_DIR}/logs_combinados_DATA.log”
```
Salve o _script_ e vá para o terminal.

No terminal, teste o comando `date`, conforme mostrado a seguir:

```
date
```
Em seguida, rode o comando date junto com as opções `+%F` para obter uma data formatada:

```
date +%F
```
Abra novamente o _script_, e substitua a palavra DATA no trecho do `cat` pelo comando date com as opções de formatação:

```
cat “${arquivo}.unico” >> “${ARQUIVO_DIR}/logs_combinados_$(date +%F).log”
```
Salve o _script_ e vá para o terminal. Utilize o comando sed para substituir no _script_ todas as ocorrências de `log_stats.txt` por um nome que utilize a data atual e também utilizando o diretório criado de _logs_ processados:

```
sed -i ‘s/log_stats.txt/”${ARQUIVO_DIR}\/log_stats_$(date +%F).txt”/’ processamento-logs.sh
```
Abra novamente o _script_ e verifique se a substituição foi feita. Depois saia do _script_ e execute-o.

Vá para o diretório `/myapp/logs-processados` e verifique os arquivos criados.

Abra o _script_ e adicione um bloco condicional `if` para salvar os  _logs_ no arquivo final de  _logs_ combinados com uma _tag_ que indique se o _log_ é do _frontend_ ou do _backend_:

```
if [[ “$nome_arquivo” == *frontend* ]]; then
  sed ‘s/^/[FRONT-END] /’ “${arquivo}.unico” >> “${ARQUIVO_DIR}/logs_combinados_$(date +%F).log”
elif [[ “$nome_arquivo” == *backend* ]]; then 
  sed ‘s/^/[BACK-END] /’ “${arquivo}.unico” >> “${ARQUIVO_DIR}/logs_combinados_$(date +%F).log”
else 
  cat “${arquivo}.unico” >> “${ARQUIVO_DIR}/logs_combinados_$(date +%F).log”
fi
```
Lembre-se de excluir a linha a seguir que estará antes do bloco `if`:

```
cat “${arquivo}.unico” >> “${ARQUIVO_DIR}/logs_combinados_$(date +%F).log”
```
Fora do laço de repetição, adicione um `sort` para ordenar os  _logs_ do arquivo final `logs-combinados`:

```
sort -k2 “${ARQUIVO_DIR}/logs_combinados_$(date +%F).log” -o “${ARQUIVO_DIR}/logs_combinados_$(date +%F).log”
```
Salve o _script_ e remova a pasta `logs-processados`. Depois execute o _script_ e verifique o arquivo de _logs_ combinados na pasta `logs-processados`.

## 6. Compactando e agendando logs
Agora aprenderemos a compactar e descompactar arquivos no formato .`tar.gz` utilizando o comando `tar`, além de agendar a execução automática de _script_s com o utilitário _cron_. Incluiremos uma etapa de compactação dos arquivos finais de _logs_ processados, criaremos uma variável para definir o diretório de destino, testaremos os comandos de listagem e extração do conteúdo compactado, e configuraremos o _cron_ para automatizar a execução do _script_ de monitoramento de _logs_ periodicamente.

No terminal, na pasta `myapp`, rode o comando a seguir para compactar a pasta `logs-processados`:

```
tar -czf logs-compactados.tar.gz logs-processados/
```
Abra o _script_ e crie um diretório temporário em uma variável, que será utilizado durante a compactação dos arquivos no _script_:

```
TEMP_DIR=”../myapp/logs-temp”
mkdir -p $TEMP_DIR
```
No final do _script_, adicione um trecho de código que move os arquivos da pasta `logs-processados` para o diretório criado acima:

```
mv “${ARQUIVO_DIR}/logs_combinados_$(date +%F).log” “$TEMP_DIR/”
mv “${ARQUIVO_DIR}/log_stats_$(date +%F).txt” “$TEMP_DIR/”
```
Logo em seguida, adicione o comando que compacta esses arquivos:

```
tar -czf “${ARQUIVO_DIR}/logs_$(date +%F).tar.gz” -C “$TEMP_DIR” .
```
Adicione um comando para renovar a pasta temporária:

```
rm -r “$TEMP_DIR”
```
Salve o _script_ e rode-o. Depois vá na pasta de `logs-processados` e veja que o arquivo compactado foi criado.

Nessa pasta, no terminal rode o comando a seguir para verificar o conteúdo do arquivo compactado:

```
tar -tzvf Nome-do-arquivo.tar.gz
```
Em seguida, rode o comando a seguir para descompactar os arquivos:

```
tar -xzvf Nome-do-arquivo.tar.gz
```
No _script_, remova a linha a seguir:

```
echo “Verificando os _logs_ no diretorio $LOG_DIR”
```
Salve o _script_.

No terminal, abra o editor do _cron_, no `crontab`, com o comando a seguir:

```
crontab -e
```
Adicione no arquivo a linha a seguir, para que o _script_ seja executado todo dia às 2 da manhã :

```
0 2 * * * /caminho/para/seu/script/monitoramento-logs.sh
```
Salve o arquivo e verifique se o `cronjob` foi agendado corretamente com o comando:

```
crontab -l
```
Para desativar a execução automática, entre novamente no `crontab` e exclua a linha adicionada.

## RETROSPECTIVA
Neste post, primeiro, vimos como criar um _script_ no Linux. Criamos nosso _script_, demos permissão de execução para ele e também fizemos a gestão de grupos em nossos diretórios.

Em seguida, complementamos nosso _script_, adicionando um laço de repetição while para percorrer todos os arquivos de _log_ e realizar o processamento desses arquivos.

Utilizamos o grep para buscar pelos _logs_ que continham informações de erro e dados sensíveis. Utilizamos o comando sed para substituir textos dentro do nosso arquivo de _logs_ filtrados. Realizamos também a ordenação desse arquivo conforme a data nas linhas dos _logs_ e removemos duplicatas desses arquivos.

Aprendemos como extrair dados desses arquivos, fazendo a extração do número de palavras e o número de linhas através do comando `wc`. Também criamos um novo arquivo que armazena esses dados estatísticos a respeito dos nossos arquivos de _log_.

Além disso, estudamos como utilizar condicionais em _script_s do Linux. Verificamos se o nome dos arquivos que estavam sendo processados continha palavras específicas como _frontend_ e _backend_. Então, realizamos a ação de adicionar uma _tag_ no início da linha desses arquivos de _logs_, indicando se é um _log_ do _frontend_ ou do _backend_.

Também concatenamos nosso arquivo em um arquivo único de _logs_ combinados, ordenamos esse arquivo de _logs_ combinados e aprendemos a compactar e descompactar esse arquivo para facilitar o envio. Por fim, vimos como podemos agendar tarefas no Linux através do agendamento da execução do nosso _script_ por meio do serviço _Cron_.
