# Rama vacía inicial
Antes que nada es necesario tener la carpeta base de sipp en el PC
Estos son los archivos que hay que incluir en la carpeta base de sipp para poder simular el intercambio de media entre un UAC y un UAS en SIPp:
  - g711a_UAS.pcap: representa la media que envía el UAS al UAC
  - uas_mod.xml: es el archivo de configuración del UAS: uas.xml original + audio añadido (g711a_UAS.pcap)
  - sipp_script.sh: es el script que ejecuta las líneas para activar UAS y UAC con una configuración concreta para iniciar el intercambio de media 


