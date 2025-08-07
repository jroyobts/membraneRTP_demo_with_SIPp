# Membrane - RTP- SIPp

Este proyecto demuestra el manejo de RTP en **Membrane** con **SIPp**.

Este ejemplo utiliza el [RTP_plugin](https://github.com/membraneframework/membrane_rtp_plugin) que es responsable de recibir y enviar flujos de RTP. Además es necesario tener instalado [SIPp](https://sipp.readthedocs.io/en/v3.6.1/installation.html).

## Ejecutando la demostración

Para ejecutar la parte de SIPp, en el directorio de la carpeta sipp:
- Dale permiso al .sh: chmod +x sipp_script.sh
- Accede al directorio en el que esté tu carpeta y ejecuta:`.\sipp_script.sh`

Para ejecutar la parte de Membrane, necesitarás tener [Elixir](https://elixir-lang.org/install.html). Luego, haz lo siguiente:

- Abre una terminal en el directorio del proyecto
- Escribe `mix deps.get` para descargar las dependencias
- Escribe en la terminal `mix run send_and_wav.exs` para correr el pipeline que recibe la media de SIpp, la procesa generando un wav y la reenvía a dos puertos distintos.
- Escribe en otras dos terminales `mix run UAC_rcv.exs` y `mix run UAS_rcv.exs` para correr los pipelines que escuchan cada uno en uno de los dos puertos a los que el pipeline anterior reenvía la media que recibe. Se generan 2 wav's por separado (uno por cada flujo de media que envían UAC y UAS).

## Copyright and License

Copyright 2018, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane)

[![Software Mansion](https://membraneframework.github.io/static/logo/swm_logo_readme.png)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane)

Licensed under the [Apache License, Version 2.0](LICENSE)
