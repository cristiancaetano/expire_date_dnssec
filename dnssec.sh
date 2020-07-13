DOMAIN=$1

if [ -z $DOMAIN ] ;then

	echo "Passar o dominio como parametro do scrit"

else

	dig_data=$(dig $DOMAIN +dnssec +short SOA | grep 'SOA' | awk -F ' ' '{print $5}' | sed 's/.\{6\}$//' | uniq )
	#pega a data de venciamento do registro SOA do dominio
	if [ -z $dig_data ] ; then

		echo "dominio $DOMAIN sem dnssec"

	else	

		CONVERTE=$(date -d "$dig_data" +%Y-%m-%d)
		#converte essa data para podermos calcular os dias restantes

		DATEATUAL=`date +%Y-%m-%d`
		#verifica a data atual

		EXPIRE=$(echo "scale=0;("`date -d "$CONVERTE" +%s`-`date -d "$DATEATUAL" +%s`")"/24/60/60|bc)

		if [ $EXPIRE -eq "0" ] ; then

			echo "CRITICAL:  $EXPIRE  $DOMAIN"

		elif [ $EXPIRE -le "5" ] ; then

			echo "CRITICAL: $EXPIRE $DOMAIN"

		elif [ $EXPIRE -le "10" ] ; then

			echo "WARNING:  $EXPIRE  $DOMAIN"

		elif [ $EXPIRE -gt "10" ] ; then 

			echo "OK:  $EXPIRE $DOMAIN"

		fi
		
	fi	
fi
