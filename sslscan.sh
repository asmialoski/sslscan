#!/bin/bash
IFS=$'\n'

cat /dev/null > urls_open_ports

#Verifica as portas abertas nas URLs passadas por parâmetro
while IFS= read -r line; do
    #echo "Text read from file: $line"
    LIST=$(nmap --script ssl-cert -p443,2443,3443,4443,5443,6443,7443,8443,9443,8080,8081,8082,2000-2010,3000-3010,4000-4010,5000-5010,6000-6010,7000-7010,8000-8010,9000-9010,14001,30000,50000-50100 $line | grep ' open ')
    for s in $LIST; do
        PORT=$(echo $s | cut -d/ -f1)
        echo "$line;$PORT"
    done >> urls_open_ports
done < "$1"

cat /dev/null > urls_ssl

#Verifica se a porta supporta SSL
while IFS= read -r line; do
    #echo "Text read from file: $line"
    url=$(echo $line | cut -d";" -f1)
    port=$(echo $line | cut -d";" -f2)
    test=$(echo "x" | timeout 10 openssl s_client -servername $url -connect $url:$port | grep 'Secure Renegotiation')
    echo "$url;$port;$test"
done < urls_open_ports >> urls_ssl

cat /dev/null > urls_ssl_supported
cat /dev/null > urls_certinfo

#Filtra apenas pelas portas que supportam SSL
cat urls_ssl | grep 'Secure Renegotiation IS supported' >> urls_ssl_supported

#Busca informações do certificado das portas que supportam SSL
while IFS= read -r line; do
    #echo "Text read from file: $line"
    url=$(echo $line | cut -d";" -f1)
    port=$(echo $line | cut -d";" -f2)
    data=`echo | openssl s_client -servername $url -connect $url:$port 2>/dev/null`
        enddate=`echo "$data" | openssl x509 -noout -text -enddate | grep notAfter= | sed -e 's#notAfter=##'`
        subject=`echo "$data" | openssl x509 -noout -text -enddate | grep Subject: | sed -e 's#Subject:##'`
    echo "$url;$port;$enddate;$subject"
done < urls_ssl_supported >> urls_certinfo
unset IFS
