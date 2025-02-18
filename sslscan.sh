#!/bin/bash
IFS=$'\n'

cat /dev/null > urls_open_ports

#Verifica as portas abertas nas URLs passadas por parâmetro
while IFS= read -r line; do
    #echo "Text read from file: $line"
    LIST=$(nmap --script ssl-cert -p443 $line | grep ' open ')
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


while IFS= read -r line; do
    #echo "Text read from file: $line"
    url=$(echo $line | cut -d";" -f1)
    port=$(echo $line | cut -d";" -f2)
    test=$(echo "x" | timeout 10 openssl s_client -servername $url -connect $url:$port -tls1_2 | grep 'Secure Renegotiation')
    echo "$url;$port;$test"
done < urls_open_ports >> urls_ssl

while IFS= read -r line; do
    #echo "Text read from file: $line"
    url=$(echo $line | cut -d";" -f1)
    port=$(echo $line | cut -d";" -f2)
    test=$(echo "x" | timeout 10 openssl s_client -servername $url -connect $url:$port -tls1_1 | grep 'Secure Renegotiation')
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
