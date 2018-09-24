# IPC-Backup-WF

## --- D E S C R I P C I O N -----
Script que se encarga de respaldar todos los workflows contenidos en un archivo de texto plano.  
En donde el archivo de texto plano está constituido por un workflow por linea.  
La variable utilizada para espaldar es $ObjectType  
El directorio de búsqueda a respaldar es la carpeta: $PwcBackupDirectory dentro del servidor PWC IPC.  
El script crea un fichero TEMPLOG.log en la ruta ${HOME}/${$(date +%d_%m_%y-%H_%M_%S)}_Backup_Workflow el cual guarda el log de la ejecución.  
En la ruta ${HOME}/${$(date +%d_%m_%y-%H_%M_%S)}_Backup_Workflow se almacenan los workflow respaldados 

# --- - - - - U S O -------------
# ejemplo:
# respaldo_ficheros_XML.sh "IPC_REPO" "UsuarioIPC" "PassIPC" "Dominio_IPC" "FOLDER_IPC_A_BUSCAR" "ARCHIVO_CON_WFs_A_RESPALDAR.txt"
