alias Membrane.Demo.RTP.ReceivePipeline
alias Membrane.WAV.Postprocessing
output_file = "ch_UAS.wav"
output_wav_path = Path.join(__DIR__, output_file)
{:ok, _supervisor, pid} =
  Membrane.Pipeline.start_link(ReceivePipeline, %{
    #video_port: 5000,
    audio_port: 6009, # Un objetivo futuro sería hacer una asignación dinámica aquí
    output_file: output_file
    #secure?: "--secure" in System.argv(),
    #srtp_key: String.duplicate("a", 30)
  }) # Entiendo que el flujo es secuencial

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
