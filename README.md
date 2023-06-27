# sslscan
Projeto pessoal

Script que passada uma lista de URLs, extraídas da zona DNS (extrair todos os registros da Zona do DNS e 
filtrar removendo estações de trabalho, registros, SOA, MX e etc), então o script roda um nmap procurando
portas abertas nessa URL, e após, para cada porta, ele verifica se a porta suporta SSL.
No final, o resultado do script é um arquivo com as URLs, portas e certificados de cada porta.
