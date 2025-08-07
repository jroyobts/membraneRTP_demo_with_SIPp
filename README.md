# Demostración de Membrane - RTP

Este proyecto demuestra el manejo de RTP en **Membrane**.

Este ejemplo utiliza el [complemento RTP](https://github.com/membraneframework/membrane_rtp_plugin) que es responsable de recibir y enviar flujos de RTP.

## Ejecutando la demostración

Para ejecutar la demostración, necesitarás tener [Elixir instalado](https://elixir-lang.org/install.html). Luego, haz lo siguiente:

- Abre una terminal en el directorio del proyecto
- Escribe `mix deps.get` para descargar las dependencias
- Escribe en la terminal `mix run send_and_wav.exs` para correr el pipeline que recibe la media de SIpp, la procesa generando un wav y la reenvía a dos puertos distintos.
- Escribe en otras dos terminales `mix run UAC_rcv.exs` y `mix run UAS_rcv.exs` para correr los pipelines que escuchan cada uno en uno de los dos puertos a los que el pipeline anterior reenvía la media que recibe. Se generan 2 wav's por separado (uno por cada flujo de media que envían UAC y UAS).



