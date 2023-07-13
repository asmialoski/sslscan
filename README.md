# SSL SCAN
Descubra as URLs onde seu certificado está sendo utilizado.

Esse script foi criado a partir da seguinte demanda: descobrir em quais URLs um certificado está sendo utilizado.  
Basicamente, o script recebe uma lista das URLs e retorna com o certificado que está sendo utilizado em cada URL.

## Execução:
 ### Rodar:
    .\sslscan.sh urls.txt

## Mas como descobrir quais são as URLs?
  Minha recomendação é exportar a lista dos registros da Zona de DNS.

## Exemplo:
  Vamos supor que eu tenha um certificado wildcard *.smialoski.com.br e preciso atualizar ele pois está vencendo.  
  Porém, eu não sei em quais URLs ele está sendo utilizado.  
  Então o procedimento seria o seguinte:  
    1. Exportar a lista dos registros da Zona de DNS smialoski.com.br;  
    2. Filtrar os registros da Zona de DNS, o objetivo é deixar a menor quantidade de URLs (excluir registros de contas de computador, por exemplo);  
    3. Executar o script passando essa lista de URLs como parâmetro.  

asdf
