#!/bin/bash
#
# AUTHOR            : JULIO CESAR PEREIRA           
# OBJETIVO          : PING VISUAL
# 
# v1.0 2022-09-21     Julio C. Pereira
#   -  
#
#
#
COUNT=1
LOOP=1
SUCCESS=0
UNSUCCESS=0
MIN=1000
MED=0
MAX=0
#
if [ -z $1 ]; then
    break
fi
IP=$1
#
mtu() {
    MTU=8
    while [ $MTU -ne 0 ]; do
        #IP=$1
        ping -c 2 -i 0.2 -W 0.3 -M do -s $MTU $IP &> /dev/null
        if [ $? -eq 0 ]; then
            #echo -e "$IP MTU\t= $MTU"
            let MTU+=20
        else
            let MTU-=20
            while [ $MTU -ne 0 ]; do
                ping -c 2 -i 0.2 -W 0.3 -M do -s $MTU $IP &> /dev/null
                if [ $? -eq 0 ]; then
                    #echo -e "$IP MTU\t= $MTU"
                    let MTU+=1
                else
                    let MTU-=1
                    if [ $MTU -ge 0 ]; then
                        echo -e "MTU\t\t: $MTU bytes"
                    fi
                    MTU=0  
                fi
            done
        fi
    done
}
#
tempo() {
    #TEMPOMIN=$(test=$(cat /tmp/pingui | grep rtt | cut -d "=" -f 2 | awk -F "/" '{print $1}') ; echo "$test-0" | bc )
    #TEMPOMED=$(cat /tmp/pingui | grep rtt | cut -d "=" -f 2 | awk -F "/" '{print $2}')
    TEMPOMAX=$(cat /tmp/pingui | grep rtt | cut -d "=" -f 2 | awk -F "/" '{print $3}')
}
#
while [ ! -z $2 ] ; do
    #echo "valor de 2 : $2"
    
    case "$2" in
        -c ) 
            shift
            delim="$2"
            if [ ! -z $delim ]; then
                C=$2
            else
                echo "Não digitou a quantidade de pacotes."
            fi
            ;;
        -t )
            shift
            delim="$2"
            if [ ! -z $delim ]; then
                F=$2
            else
                echo "Não digitada frequência de envio!" ; echo
            fi
            ;;   
        -m )
            shift
            delim="$2"
            if [ ! -z $delim ]; then
                M=$2
            else
                echo "Não especificado se deve testar MTU (s|n)!" ; echo
            fi
            ;;         
        *) 
            echo -e "Opção incorreta !" ;
            echo 
            ;;
    esac
    shift
done

if [ ! -z $C ]; then
    echo -n
else
    C=10
fi

if [ ! -z $F ]; then
    echo  -n
else
    F=1
fi

if [ ! -z $M ]; then
    M=$(echo "$M" | tr '[:upper:]' '[:lower:]')
else
    M=n
fi
echo -e "----------------------------------------[$(date +%H:%M:%S.%3N)]----------------------------------------------"
#A=$(date +%H%M%S%3N)
while [ $COUNT -le $C ]; do
    #ping $IP -c 1 -W $F > /dev/null
    ping $IP -c 1 -W $F  > /tmp/pingui
    if [ $? -eq 0 ]; then
        if [ $LOOP -le 100 ]; then
            echo -ne "!"
            let LOOP++
            let SUCCESS++
            tempo
            if [ $(echo "$TEMPOMAX >= $MAX" | bc) -eq 1 ]; then
                MAX="$TEMPOMAX"
            fi
            MED=$(echo "$TEMPOMAX+$MED" | bc)
            if [ $(echo "$TEMPOMAX <= $MIN" | bc) -eq 1 ]; then
                MIN="$TEMPOMAX"
            fi
        else
            LOOP=1
            echo -e "!"
            let LOOP++
            let SUCCESS++
            tempo
            if [ $(echo "$TEMPOMAX >= $MAX" | bc) -eq 1 ]; then
                MAX="$TEMPOMAX"
            fi
            MED=$(echo "$TEMPOMAX+$MED" | bc)
            if [ $(echo "$TEMPOMAX <= $MIN" | bc) -eq 1 ]; then
                MIN="$TEMPOMAX"
            fi
        fi
    else
        if [ $LOOP -le 100 ]; then
            echo -ne "."
            let LOOP++
            let UNSUCCESS++
        else
            LOOP=1
            echo -e "."
            let LOOP++
            let UNSUCCESS++
        fi
    fi 
    let COUNT++
done
echo -e "\n----------------------------------------[$(date +%H:%M:%S.%3N)]----------------------------------------------"
#Z=$(date +%H%M%S%3N)
PERCSU=$(echo "($SUCCESS*100)/$COUNT" | bc)
PERCUN=$(echo "($UNSUCCESS*100)/$COUNT" | bc)
echo -e "RETORNO\t\t: $SUCCESS\t ($PERCSU %)"
echo -e "PERDAS\t\t: $UNSUCCESS\t ($PERCUN %)"
if [ $SUCCESS -ne 0 ]; then
    echo -e "TEMPO MAX\t: $MAX ms"
    MED=$(echo "$MED/$COUNT" | bc)
    echo -e "TEMPO MED\t: $MED ms"
    echo -e "TEMPO MIN\t: $MIN ms"
    if [ "$M" == "s" ]; then
        mtu
    fi
fi

