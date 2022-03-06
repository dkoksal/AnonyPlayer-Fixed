#!/bin/bash 
####### Auto Tuning Script for AnonyRadio via torsock by z01db3rg ##########
####### Tested on Ubuntu 12.04.1 LTS - VLC 2.0.3 - TOR 0.2.2.35-1 ##########
############################################################################
log="/tmp/radiator.log"
run="/var/run/tor"
pid="$run/tor.pid"

TTY=$(tty | sed s@/dev/@@)
script=`ps $$ | awk -F ' ' '{print $6}'`
name=$(ps -ad | grep $$ | awk -F ' ' 'NR == 1 {print $4}')
[ -n $TTY ] && vlcuser=$(w -fh | grep $TTY | awk -F ' ' 'NR == 1 {print $1}') || exit

main () {

clear
echo "################### \\\\\\\\\\\\\\\\ AnonyPlayer //////// \
######################"
echo "######### ********* - Ubuntu Linux Version 0.1 - ********** \
###########"
echo "################### ///////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\ \
######################"
back () {
if [ -z "$vlc" ]; then
        exit
else
sleep 20 && jit
fi
	}


internet () {
	rm -f /tmp/Ok.txt &> /dev/null
	vlc=`ps -ad | grep vlc`
if [ $USER == "root" ]; then
su - $vlcuser -c "wget -q --tries=10 --timeout=5 http://www.google.com -O /tmp/Ok.txt" &> /dev/null
else
wget -q --tries=10 --timeout=5 http://www.google.com -O /tmp/Ok.txt &> /dev/null
   fi

if [ ! -s /tmp/Ok.txt ];then
	echo "You are not connected!! Please check..." && back
else
	rm -f /tmp/Ok.txt
[ -z "$vlc" ] && echo "You are connected and the DNS works."
	return
fi
}

http=`which wget`

[ -x $http ] && internet

user=`whoami`
echo -n "AnonyPlayer is running as user=$user..."
if [ "$user" != "root" ]; then
echo "   Ko! "
echo "***** The script must run as root!! *****"
echo "Now I try by myself..." && sleep 2 
[ -x "$(which sudo)" ] || echo "***** Install sudo!! *****" 

LOCATE () {
if [ ! -x "$(which mlocate)" ]; then
sudo apt-get install -f -y mlocate
fi
sudo updatedb.mlocate 
scripath=`(sudo locate $name|grep -v swp|head -n1)`
echo -n "I copy the script!! " 
sudo cp -av $scripath /usr/local/bin/ && sleep 2 && sudo /usr/local/bin/$name
	  }

if [ -n "$script" ]; then
clear && echo "***** I'm running the script $name as root!! *****" 
sleep 2 && sudo $script $radio
else 
LOCATE
fi
exit
else
echo " OK!"
fi

vlc=`which vlc`

tor=`which tor`

if [ -x "$vlc" ] && [ -x "$tor" ]; then

true

else

echo "--------------------------------------------------"
echo "******* VLC and/or TOR are not installed!! *******"
echo "--------------------------------------------------"
echo "I got it because  you look like a little clumsy..."
echo "--------------------------------------------------"

sudo apt-get install vlc tor alsa-utils -f -y || exit

fi

echo "VLC will run as user=$vlcuser."

torstatus () {
sudo service tor status| grep not
             } 

tor () {

if [ -z "$tor" ]; then

/bin/true

else

echo -n "TOR starting..."

sudo service tor start >/dev/null 2>&1 && [ -f $pid ] && echo -n " ok!" || sudo service tor start || exit

return
fi
   }

torstatus && tor $1

avvio () {

torstatus && tor $1

torsocks=`which torsocks`

if [ -x "$torsocks" ]; then

torify=$torsocks

else

torify=$(which torify) && echo -n "***** It's better installing torsocks... but I try to connect though as I try to install it...*****" & sudo apt-get install torsocks -f -y &> /dev/null

fi

sudo -H -u $vlcuser $torify cvlc --play-and-exit http://$station/$stream > $log  2>&1 &

    }

echo ""
echo "                 ++++++++++++++++++++++++++++++++++++"
echo "                 + Connecting to the radio station! +"
echo "                 ++++++++++++++++++++++++++++++++++++"
echo ""
echo "			  *** $stream ***"         
echo ""
echo -n "Tuning..."

[ -x "`which alsamixer`" ] && [ -x "`which xterm`" ] && sudo -u $vlcuser xterm alsamixer 2> /dev/null & avvio

error ()  {


COUNTER=20

until [  $COUNTER -eq 0 ]; do

check_start () {

sleep 10 

err=`grep "mp3" $log`

if [ -z "$err" ]; then

echo -n "..."

pkill vlc

avvio

else

echo "."
echo ""
echo "                   ----------------------------------"
echo "                   - Radio clandestina connected! :-)"
echo "                   ----------------------------------"
echo ""

	jit
      return

   fi

   }

check_start

let COUNTER-=1

done

check_start 

echo "."
echo "Unknown problem in attempting to connect ... the dj is on holiday? :-(

" && pkill vlc && exit 
   }


jit () {

while /bin/true; do

[ -x $http ] && internet 

ignored=`(grep ignored /tmp/radiator.log | tail -n 1)`
jitter=`(tail -n 2 $log | grep increased | awk -F ' ' '{print $13}' | tail -n 1)`
umount=`grep unmounting $log` 
proc=`(ps -ad | grep vlc)`

check_jitter () {
if [ "$jitter" -lt "5000" ] && [ -z "$ignored" ] && [ -n "$proc" ] && [ -z "$umount" ]; then
echo "The latency is increased to $jitter ms: over 5 seconds I try a new circuit..." &&  echo -e {"+","\n+"} >> $log 
continue
else 
echo "The latency is increased to $jitter ms: I look for a new circuit..." &&  echo -e {"+","\n+"} >> $log
/bin/sed -i 's/^#ControlPort 9051/ControlPort 9051/ ; s/^#CookieAuthentication 1/CookieAuthentication 1/' /etc/tor/torrc
circuit () {
printf "AUTHENTICATE \"`cat $run/control.authcookie`\"\r\nSIGNAL NEWNYM\r\n" | nc 127.0.0.1 9051
	}
[ -f $run/control.authcookie ] && circuit || sudo service tor restart &> /dev/null
continue
fi
	}

if [ -n "$jitter" ]; then

check_jitter

elif [ -z "$ignored" ] && [ -n "$proc" ] && [ -z "$umount" ] ; then

sleep 10

else 

Restart

fi

done
   }

Restart () {

echo "*** I have problems with the stream, try again to tune in!! ***"

[ -x $http ] && internet 

pkill vlc
sudo service tor restart >/dev/null 2>&1 

sleep 3
echo -n "Tuning..."

COUNTER=10
     avvio $1
	error
           }

error 

}

radio="$1"
address=$(echo $radio | grep .onion | sed -e 's@http://@@' -e 's/\(.*\.onion\).*/\1/' | wc -m)

if [ "$address" == "23" ]; then
station=`$radio|sed 's@http://@@'`
else
station="anonyradixhkgh5myfrkarggfnmdzzhhcgoy2v66uf7sml27to5n2tid.onion"
  case "$1" in
	jazz|AnonyJazz)
	    stream=AnonyJazz
	;;
        country|AnonyCountry)
	    stream=AnonyCountry
	;;
	*)
	    stream=AnonyRadio
	;;
  esac
fi
main 

exit
