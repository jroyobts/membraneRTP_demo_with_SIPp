# Archivos a incluir en la carpeta sipp
Para ejecutar la demo, estos son los archivos necesarios que hay que incluir en la carpeta base `sipp` que se obtiene al instalar SIPp.
- g711a_UAS.pcap: es el archivo que contiene la media que envía el UAS al UAC.
- sipp_script.sh: es el archivo que ejecuta las líneas de 'sipp ...' con la configuración dada para UAC y UAS.
- uas_mod.xml: es el archivo de configuración del UAS. Se ha creado partiendo de uno predeterminado y añadiendole la media
  del UAS (g711a_UAS.pcap).
El archivo de configuración utilizado para el uac no se incluye porque es predeterminado: `/home/user/sipp/docs/uac_pcap.xml`




