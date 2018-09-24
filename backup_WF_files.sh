#!/bin/bash

#      ___           ___           ___           ___           ___     
#     /  /\         /  /\         /  /\         /  /\         /__/\    
#    /  /::\       /  /::|       /  /:/_       /  /:/_       |  |::\   
#   /  /:/\:\     /  /:/:|      /  /:/ /\     /  /:/ /\      |  |:|:\  
#  /  /:/~/::\   /  /:/|:|__   /  /:/ /:/_   /  /:/ /:/_   __|__|:|\:\ 
# /__/:/ /:/\:\ /__/:/ |:| /\ /__/:/ /:/ /\ /__/:/ /:/ /\ /__/::::| \:\
# \  \:\/:/__\/ \__\/  |:|/:/ \  \:\/:/ /:/ \  \:\/:/ /:/ \  \:\~~\__\/
#  \  \::/          |  |:/:/   \  \::/ /:/   \  \::/ /:/   \  \:\      
#   \  \:\          |  |::/     \  \:\/:/     \  \:\/:/     \  \:\     
#    \  \:\         |  |:/       \  \::/       \  \::/       \  \:\    
#     \__\/         |__|/         \__\/         \__\/         \__\/    
#---------------------------------------------------azeem@redirac.com--


# --- D E S C R I P C I O N -----#
# Script que se encarga de respaldar todos los workflows contenidos en un archivo de texto plano.
# En donde el archivo de texto plano está constituido por un workflow por linea.
# La variable utilizada para espaldar es $ObjectType
# El directorio de búsqueda a respaldar es la carpeta: $PwcBackupDirectory dentro del servidor
# PWC IPC 
# El script crea un fichero TEMPLOG.log en la ruta ${HOME}/${$(date +%d_%m_%y-%H_%M_%S)}_Backup_Workflow
# el cual guarda el log de la ejecución.
# En la ruta ${HOME}/${$(date +%d_%m_%y-%H_%M_%S)}_Backup_Workflow se almacenan los workflow respaldados


# --- - - - - U S O -------------#
# ejemplo:
# respaldo_ficheros_XML.sh "IPC_REPO" "UsuarioIPC" "PassIPC" "Dominio_IPC" "FOLDER_IPC_A_BUSCAR" "ARCHIVO_CON_WFs_A_RESPALDAR.txt"


#---------------------------------------
# Declaring IPC connection variables

# Repository Name = Nombre del Repositorio IPC. 
RepositoryName=$1

# UserName = Nombre del usuario para la conexión con IPC.
UserName=$2

# Contraseña de Usuario $UserName de IPC
PassUser=$3

# PWC_DOMAIN = dominio IPC (desarrollo)
PWC_DOMAIN=$4

# (Folder dónde se encuentran los objetos a respaldar)
PwcBackupDirectory=$5

#--------------------------------------
# Declaring Backup IPC Variables

# Object Type (always workflow in this case)
ObjectType="workflow"

# Creating workflow backup directory

FecTemp=$(date +%d_%m_%y-%H_%M_%S)

FullBackupPath=${HOME}/${FecTemp}_Backup_Workflow


FullLogPath=$FullBackupPath/TEMPLOG.log

touch $FullLogPath


echo "------------------------------------------------------------------------------------"
echo "- - - -  R E S P A L D O  A R C H I V O S  X M L  -  P W C   $PwcBackupDirectory- - - -"
echo "------------------------------------------------------------------------------------"
echo 
mkdir ${FullBackupPath}
echo "------------------------------------------------------------------------------------"
echo "---- Directorio De Respaldo: ${FullBackupPath}---------"
echo "-------- Archivo .log: $FullLogPath"
echo "------------------------------------------------------------------------------------"


# -------------------------------------------------

# Estructura general del comando pmrep
# ->pmrep connect -r $RepositoryName -n $UserName -x $PassUser -d $PWC_DOMAIN


# Estableciendo conexión con el repositorio IPC

#echo "pmrep connect -r $RepositoryName -n $UserName -x $PassUser -d $PWC_DOMAIN"
pmrep connect -r $RepositoryName -n $UserName -x $PassUser -d $PWC_DOMAIN  | tee -a $FullLogPath
#echo "CONEXION SUCCED"
#0 = exito; 1= error
if [ $? -eq 0 ];
then
	echo "------------------------------------------------------------------------------------"
	echo "------- C O N E X I Ó N  C O N   P W C:  E X I T O S A  ------"
	echo "------------------------------------------------------------------------------------"
	echo
	# Lectura de Archivo de entrada y demás parámetros
	echo "------------------------------------------------------------------------------------"
	echo "- - - - - - -  G E N E R A L  I N F O - - - - - -  - - - -"
	echo "------------------------------------------------------------------------------------"

	# Recibe cómo parametro el fichero a utilizar 
	Fichero=$6

	echo "Nombre del archivo: $Fichero"

	#Calculando el total de lineas en el archivo: 

	NumOfLines=$(sed -n '=' ${Fichero} | wc -l)

	echo "Total de archivos contenidos en: $Fichero = $NumOfLines"

	# Variable conatdor para identificacion visual del proceso
	contador=1
	# Variable contador de archivos respaldados
	ArchivosRespaldados=0
	# Variable contador de archivos no respaldados
	ArchivosNoRespaldados=0

	# Leyendo la primer fila y obteniendo parámetros generales

	GeneralFirstFileName=$(head -n 1 $Fichero)

	# String Sanitizer. 
	# Removing the \r at the end of the GeneralExt
	# For reference: https://stackoverflow.com/questions/20242488/string-comparison-in-bash-script-not-working-as-expected


	echo "Primer Nombre de Fichero (XML): $GeneralFirstFileName"


	echo "- - - - - E N D   I N F O - - - - - -"
	echo

	# Aqui entra el While 

	while IFS="" read -r RowFileName || [ -n "${RowFileName}" ]
	do
	  echo
	  echo " - - - - - - - A R C H I V O - - - - - - - -" | tee -a $FullLogPath
	  echo "Trabajando en el archivo $contador del total = $NumOfLines" | tee -a $FullLogPath
	  #echo "Nombre de archivo RowFileName: $RowFileName"
	  TempFullFileName=$(basename -- "$RowFileName")
	  TempFileName="${TempFullFileName%.*}"
	  TempFileExt="${TempFullFileName##*.}"

	  # Cleaning all the Parameters from \r
	  TempFullFileName=$(echo $TempFullFileName | tr -d '\r')
	  TempFileName=$(echo $TempFileName | tr -d '\r')
	  TempFileExt=$(echo $TempFileExt | tr -d '\r')
	  RowFileName=$(echo $RowFileName | tr -d '\r')

	  FullXmlBackupPath=$FullBackupPath/$RowFileName.XML

	  echo "Nombre del Fichero $RowFileName" | tee -a $FullLogPath

	  ValidacionTemporal="$FullBackupPath/validate-$RowFileName"
 
	  # Comprobando que exista el Workflow en el repositorio PWC con un validate
	  echo "pmrep validate -n $RowFileName -o $ObjectType -f $PwcBackupDirectory" | tee -a $FullLogPath
	  pmrep validate -n $RowFileName -o $ObjectType -f $PwcBackupDirectory >> $ValidacionTemporal | tee -a $FullLogPath
	  #validate {{-n <object_name> -o <object_type (mapplet, mapping, session, worklet, workflow)> [-v <version_number>] [-f <folder_name>]} | -i <persistent_input_file>} [-s (save upon valid) [-k (check in upon valid) [-m <check_in_comments>]]] [-p <output_option_types (valid, saved, skipped, save_failed, invalid_before, invalid_after, or all)> [-u <persistent_output_file_name>] [-a (append)] [-c <column_separator>] [-r <end-of-record_separator>] [-l <end-of-listing_indicator>] [-b (verbose)] 

	  #hacer grep a la validacion para ver que falla o exito

	  grep "Failed to execute validate." $ValidacionTemporal #>> VALIDA.t1
	  # si la validacion fue exitosa, procede con el export, si no reportalo
	  # 0-> exito
	  # 1-> error
	  # da un error en la búsqueda, por lo tanto el workflow existe 
	  if [ $? -eq 1 ];
	  then
	  echo " - - - - - V A L I D A C I O N  E X I T O S A - - - - - " | tee -a $FullLogPath
	  echo
	  echo " - - - - - I N I C I A N D O  E X P O R T  D E L  W O R K F L O W  - - - - -" | tee -a $FullLogPath
	  echo "premp objectExport -n $RowFileName -o $ObjectType -m -s -b -r -u $FullXmlBackupPath -f $PwcBackupDirectory" | tee -a $FullLogPath
	  echo "Respaldando el  WorkFlow: $RowFileName" | tee -a $FullLogPath
	 #Exportando el WF: $ObjectName en el directorio $PwcBackupDirectory ($RowFileName)
	  pmrep objectExport -n $RowFileName -o $ObjectType -m -s -b -r -u $FullXmlBackupPath -f $PwcBackupDirectory | tee -a $FullLogPath
	  echo "- - - R E S P A L D O   E X I T O S O - - -"  | tee -a $FullLogPath

	let ArchivosRespaldados++


		else #cuando no encuentra el archivo
		echo
		echo " - - - N O  S E  E N C U E N T R A  E L  W O R K F L O W - - - " | tee -a $FullLogPath
		echo " - - - WF NAME  =  $RowFileName" | tee -a $FullLogPath


		let ArchivosNoRespaldados++ 

		fi # cierra fi para validar que existe el archivo en PWC folder


	# Actualizacion del contador general 
	let contador++
	# Cierra el While que itera sobre los elementos del archivo $Fichero
	done < $Fichero

	echo "- - - G E N E R A L  -  R E S U L T S - - -" | tee -a $FullLogPath
	echo "Encontré un total de Archivos:  $ArchivosRespaldados" | tee -a $FullLogPath
	echo "No encontré un total de Archivos: $ArchivosNoRespaldados" | tee -a $FullLogPath

# Else para comprobar error en la conexión con PWC
elif [ $? -eq 1 ];
	then
		echo "------------------------------------------------------------------------------------" | tee -a $FullLogPath
		echo "-------- E R R O R   E N   L A   C O N E X I Ó N    P W C  ---------" | tee -a $FullLogPath
		echo "------------------------------------------------------------------------------------" | tee -a $FullLogPath
		echo "Verifica tus parámetros: UserName:$UserName y PassUser:$PassUser" | tee -a $FullLogPath
		# Borra el directorio de respaldo creado al inicio
		mkdir ${FullBackupPath}

fi # Closes General if 

# Fuera del While


# Cerrando Conexión y limpiando 
pmrep cleanup