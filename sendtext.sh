#!/bin/bash
# requires the feh package
                                # if @a is empty, then enter own message
if [ -z $@ ] 
then
    echo "enter message: "
    read message
    msg=$message
else
    msg=$@
fi

                                 # make order request
e=$(curl -F "bid=1" -F "message=$msg" https://api.blockstream.space/order) 
d=$(echo $e | grep -o '[0-9\.]* millisatoshis\.' | grep -o -E '[0-9]{2,}')
s=$(curl -F "bid=$d" -F "message=$msg" https://api.blockstream.space/order)
dsats=$(echo "scale=3; $d/1000" | bc)


                                 # Confirm payment
while true; do
    read -p "Do you wish to pay $dsats sats? (y/n)" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
n=$(echo $s | grep -o 'payreq...[^\",]*' | grep -o -E '[^\",]{10,}')
qrencode -o pay.png $n           # generate qr code
feh -Z pay.png &              # run process in background to open qr image
u=$(echo $s | grep -o 'uuid...[^\",]*.,' | grep -o -E '[^\",]{10,}')
a=$(echo $s | grep -o 'auth_token...[^\",]*.,' | grep -o -E '[^\",]{18,}')

r=$(curl -v -H "X-Auth-Token: $a" https://api.blockstream.space/order/$u)
b=$(echo $r | grep -o 'unpaid_bid..[^\",]*' | grep -o -E '[0-9]*')
                                 # wait for bid to be accepted
while [ $b -ne "0" ]
do
    echo "bid not paid"
    sleep 5
    r=$(curl -v -H "X-Auth-Token: $a" https://api.blockstream.space/order/$u)
    b=$(echo $r | grep -o 'unpaid_bid..[^\",]*' | grep -o -E '[0-9]*')
done

pidof feh && pkill feh           # closes qr image
rm pay.png                       # deletes qr image
echo "bill paid, message sent to satellite"

