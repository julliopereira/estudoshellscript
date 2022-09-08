#!/bin/bash
#
#
#
# QUANTIDADE DE PACOTES A SEREM TESTADOS INICIALMENTE:
PKTS=15
#
VERD="\033[42;37;1m"
VERM="\033[47;37;5m"
STRO="\033[47;30;5m"
CLEAR="\033[m"
#
func_help() {
    clear
    echo -e "
    Use:    $(basename $0) [ip|name]... [opc]...
            connection test with icmp packet


            opc:
                - 1 ,          connection status test
                - 2 ,          variation between min and max time
                - 3 ,          connection quality (packet losses)
                - 4 ,          maximum MTU size
                - h , --help   help


            example:
                $(basename $0) 10.0.2.105 3
    "
}
#
func_data() {
    # data e hora atual
    DATA=$(date +%Y%m%d_%H:%M:%S)
}
#
func_pkts() {
    # quantidade de pacotes para teste de erros
    echo -e -n "\t- Quantidade de PACOTES encaminhados para teste de ERROS: "; read PKTS
}
#
func_conn() {
    # [1] conexão / tempo de resposta [méd] / qtd de pacotes recebidos
    func_data
    MEDIA=$(cat /tmp/$IP'ping'.txt | egrep "rtt" | cut -d '=' -f 2 | cut -d '/' -f 2)
    RECEB=$(cat /tmp/$IP'ping'.txt | grep "received" | cut -d ',' -f 2 | awk -F ' ' '{print $1}')
    echo -e "\t- Ping \t\t : OK "
    echo -e "\t- Média\t\t : $MEDIA ms \t[ $PKTS pkts ]"
    if [ $RECEB -eq $PKTS ]; then
        echo -e "\t- Recebidos\t : $RECEB \t\t[ $PKTS pkts ]"
    else
        echo -e "\t- Recebidos\t : $RECEB \t\t[ $PKTS pkts ]\t<<"
    fi
    echo -e "============================================================================="
}
#
func_variacao() {
    # [2] variacao entre o menor e maior tempo de resposta
    MIN=$(cat /tmp/$IP'ping'.txt | egrep "rtt" | cut -d '=' -f 2 | cut -d '/' -f 1)
    MAX=$(cat /tmp/$IP'ping'.txt | egrep "rtt" | cut -d '=' -f 2 | cut -d '/' -f 3)
    VARIACAO=$(bc<<<$MAX-$MIN)
    echo -e "\t- Variação\t : $VARIACAO ms\t[ Max-Min ]" 
    echo -e "============================================================================="
}
#
func_err() {
    # [3] testar varios tamanhos de pacotes
    # mostrar quantos pacotes recebidos 
    echo -e ""
    for SIZE in 200 400 600 800 1000 1200 1300 1400; do
        ping $IP -c $PKTS -i 0.2 -W 1 -p AAAA -s $SIZE > /tmp/$IP'ping'.txt
        RECEB=$(cat /tmp/$IP'ping'.txt | grep "received" | cut -d ',' -f 2 | awk -F ' ' '{print $1}')
        if [ $RECEB -eq $PKTS ]; then
            echo -e "\t- Recebidos1\t : $RECEB \t\t[ $PKTS pkts | MTU: $SIZE ]"
        else
            echo -e "\t- Recebidos1\t : $RECEB \t\t[ $PKTS pkts | MTU: $SIZE ]\t<<"
        fi
    done
    for SIZE in 200 400 600 800 1000 1200 1300 1400; do
        ping $IP -c $PKTS -i 0.2 -W 1 -p FFFF -s $SIZE > /tmp/$IP'ping'.txt
        RECEB=$(cat /tmp/$IP'ping'.txt | grep "received" | cut -d ',' -f 2 | awk -F ' ' '{print $1}')
        if [ $RECEB -eq $PKTS ]; then
            echo -e "\t- Recebidos2\t : $RECEB \t\t[ $PKTS pkts | MTU: $SIZE ]"
        else
            echo -e "\t- Recebidos2\t : $RECEB \t\t[ $PKTS pkts | MTU: $SIZE ]\t<<"
        fi
    done
    #echo -e "ERR\t:EM DESENVOLVIMENTO ..."
    echo -e "============================================================================="
}
#
func_trace() {
    # [4] Traceroute até para o destino
    echo -e "TRACE\t:EM DESENVOLVIMENTO ..."
    echo -e "============================================================================="
}
#
func_mtu() {
    # [5] testar maximo MTU possível
    echo -e "MTU\t:EM DESENVOLVIMENTO ..."
    echo -e "============================================================================="
}
#
clear 
echo -e "AGUARDE ..."
if [[ $1 == "-h"  ||  $1 == "--help" ]]; then
    func_help
else
    if [ -z $1 ]; then 
        func_help
    else
        for IP in $(echo $1); do
            ping $IP -c $PKTS -i 0.2 -W 1 > /tmp/$IP'ping'.txt
            if [ $? -eq 0 ]; then
                if [ -z $2 ]; then 
                    func_conn
                else
                    clear
                    echo -e "INICIO> $STRO $IP $CLEAR [data/hora: $DATA]:"
                    echo -e "============================================================================="
                    case $2 in   
                        1) func_conn ;;
                        2) func_conn; func_variacao ;;
                        3) func_conn; func_variacao; func_pkts; func_err ;;
                        4) func_conn; func_variacao; func_pkts; func_err; func_trace ;;
                        5) func_conn; func_variacao; func_pkts; func_err; func_trace; func_mtu ;;
                        -h|--help) func_help ;;
                        *) echo -e "INFORMAÇÃO INCORRETA, TENTE NOVAMENTE..." ;;
                    esac
                fi
                func_data
                echo -e "FIM   > $STRO $IP $CLEAR [data/hora: $DATA]:"
            else
                clear
                func_data
                echo -e "IP $STRO $IP $CLEAR [data/hora: $DATA]:"
                echo -e "\t- Ping \t\t : NÃO ACESSÍVEL \t<<"
            fi
        done
    fi
fi
#
#func_data
#echo -e "FIM   > $STRO $IP $CLEAR [data/hora: $DATA]:"
#rm -f /tmp/$IP'ping'.txt



