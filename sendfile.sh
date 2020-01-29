#!/bin/bash
u=()
a=()
t=()
c=0
for f in "$@"
do
    e=$(curl -F "bid=1" -F "file=@$(readlink -f $f)" https://api.blockstream.space/order)
    d=$(echo $e | grep -o '[0-9\.]* millisatoshis\.' | grep -o -E '[0-9]{2,}')
    s=$(curl -F "bid=$d" -F "file=@$(readlink -f $f)" https://api.blockstream.space/order)
    n=$(echo $s | grep -o 'payreq...[^\",]*' | grep -o -E '[^\",]{10,}')
    b=$(basename $f)
    > "${b%.*}-pay.png"
    qrencode -o "${b%.*}-pay.png" "$n"
    t+=("${b%.*}-pay.png")
    u+=("$(echo $s | grep -o 'uuid...[^\",]*.,' | grep -o -E '[^\",]{10,}')")
    a+=("$(echo $s | grep -o 'auth_token...[^\",]*.,' | grep -o -E '[^\",]{18,}')")
    c=$((c+1))
done
while [ $c -ne 0 ]
do
    echo "------------------------------------------------------------------"
    echo "$c bids not paid"
    sleep 20
    for i in $(seq 0 $((c-1)))
    do
        b=$(curl -v -H "X-Auth-Token: ${a[$i]}" https://api.blockstream.space/order/${u[$i]} | grep -o 'unpaid_bid..[^\",]*' | grep -o -E '[0-9]*')
        echo https://api.blockstream.space/order/${u[$i]} 
        if [ $b -eq 0 ] 
        then
            rm ${t[$i]}
            a=("${a[@]:0:$i}" "${a[@]:$((i+1))}")
            u=("${u[@]:0:$i}" "${u[@]:$((i+1))}")
            t=("${t[@]:0:$i}" "${t[@]:$((i+1))}")
            c=$(($c-1))
        fi
    done
done
