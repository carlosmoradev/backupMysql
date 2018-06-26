#!/bin/bash
# Shell script para hacer backup de las bases de datos MySql  
 
USUARIO=$(base64 -d usrRespaldo)     # Usuario que realiza el respaldo
PASSWORD=$(base64 -d pwdRespaldo)
SERVIDOR="localhost"          # Servidor a respaldar
 
# Paths de aplicaciones en linux
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
CHOWN="$(which chown)"
CHMOD="$(which chmod)"
GZIP="$(which gzip)"
 
# Directorio de destino para el respaldo
DEST="/home/backups"
 
# Directorio Principal donde se almacenaaran las bases de datos
MBD="$DEST/mysql"
 
# Obtiene el nombre del servidor
HOST="$(hostname)"
 
# Obtener la fecha para nombrar las copias
FECHA="$(date +"%d-%m-%Y")"
 
# Archivo para almacenar algun backup recurrente
ARCHIVO=""
# Listado de bases de datos a respaldar
DBS=""
 
# No haga respaldo a las siguientes bases de datos
OMITA="information_schema"
 
[ ! -d $MBD ] && mkdir -p $MBD || :
 
# Modifica permisos para que solo el root pueda acceder
$CHOWN 0.0 -R $DEST
$CHMOD 0600 $DEST
 
# Primero se genera un listado de todas las bases de datos disponibles
DBS="$($MYSQL -u $USUARIO -h $SERVIDOR -p$PASSWORD  -Bse 'show databases')"

clear

for db in $DBS
do
   omitedb=-1
    if [ "$OMITA" != "" ];
    then
        for i in $OMITA
        do
            [ "$db" == "$i" ] && omitedb=1 || :
        done
    fi
 
    if [ "$omitedb" == "-1" ] ; then

echo "respaldando $db "
echo -e "por favor espere"
echo
echo
        ARCHIVO="$MBD/$db.$HOST.$FECHA.gz"
        $MYSQLDUMP -u $USUARIO -h $SERVIDOR $db -p$PASSWORD | $GZIP -9 > $ARCHIVO
    fi
done