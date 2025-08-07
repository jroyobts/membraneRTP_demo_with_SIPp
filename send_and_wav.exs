alias Membrane.Demo.RTP.ReceivePipeline_SIPp
alias Membrane.WAV.Postprocessing

# Ruta del archivo WAV de salida
output_wav_path = Path.join(__DIR__, "output.wav")

{:ok, _supervisor, pid} =
  Membrane.Pipeline.start_link(ReceivePipeline_SIPp, %{

    # Esta información tendría que adquirirse de un SDP
    audio_port_src1: 6000,
    audio_port_src2: 6003,
    audio_port_dst1: 6006,
    audio_port_dst2: 6009

  })

# Esto es para acabar generando el .wav correctamente
spawn(fn ->
  IO.puts("Pipeline iniciado. Presiona ENTER para terminar y aplicar postprocessing...")
  IO.gets("")

  IO.puts("Terminando pipeline...")
  Membrane.Pipeline.terminate(pid)

  # Esperar un poco para que el archivo se complete
  Process.sleep(1000)

  # Aplicar postprocessing
  if File.exists?(output_wav_path) do
    IO.puts("Aplicando postprocessing a #{output_wav_path}...")

    case Postprocessing.fix_wav_header(output_wav_path) do
      :ok ->
        IO.puts("Postprocessing completado exitosamente")
        System.halt(0)
      {:error, reason} ->
        IO.puts("Error en postprocessing: #{inspect(reason)}")
        System.halt(1)
    end
  else
    IO.puts("Archivo WAV no encontrado: #{output_wav_path}")
    System.halt(1)
  end
end)

# Mantener el proceso principal vivo
Process.sleep(:infinity)
