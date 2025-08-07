defmodule Membrane.Demo.RTP.ReceivePipeline do
  use Membrane.Pipeline
  require Logger
  alias Membrane.{G711, RTP, UDP}
  alias Membrane.File.Sink

  @local_ip {127, 0, 0, 1}
  @impl true
  def handle_init(_ctx, opts) do
    %{audio_port: audio_port} = opts

    spec = [
      child(:rtp, %RTP.SessionBin{
        fmt_mapping: %{
          8 => {:G711, 64_000},  # G.711 PCMA/PCMU
          101 => {:telephone_event, 8_000}  # DTMF eventos telefónicos
        }
      }),

      child(:audio_src, %UDP.Source{
        local_port_no: audio_port,
        local_address: @local_ip
      })
      |> via_in(:rtp_input)
      |> get_child(:rtp)
    ]

    {[spec: spec], opts}
  end

  @impl true
  def handle_child_notification({:new_rtp_stream, ssrc, 8, _extensions}, :rtp, _ctx, state) do
    Logger.info("Detectado stream G.711 con SSRC: #{inspect(ssrc)}")
    state = Map.put(state, :audio_ssrc, ssrc)
    actions = handle_stream(state)
    {actions, state}
  end

  @impl true
  def handle_child_notification({:new_rtp_stream, ssrc, 101, _extensions}, :rtp, _ctx, state) do
    Logger.info("Detectado stream de eventos telefónicos (DTMF) con SSRC: #{inspect(ssrc)}")
    # Aquí podrías procesar los eventos DTMF si es necesario
    # Por ahora solo registramos que se recibieron pero no los procesamos
    {[], state}
  end

  @impl true
  def handle_child_notification(
    {:new_rtp_stream, _ssrc, encoding_name, _extensions},
    :rtp,
    _ctx,
    _state
  ) do
    raise "Codificación no soportada: #{inspect(encoding_name)}"
  end

  @impl true
  def handle_child_notification({:connection_info,_local_ip, _port}, :audio_src, _ctx, state) do
    Logger.info("Fuente UDP de audio conectada.")
    {[], state}
  end

  #defp handle_stream(%{audio: audio_ssrc, output_file: output_file}) do
  defp handle_stream(state) do
    audio_ssrc = Map.get(state, :audio_ssrc)
    output_file = state.output_file
    spec =
      {[
        child(:tee,Membrane.Tee.Master),
        get_child(:rtp)
        |> via_out(Pad.ref(:output, audio_ssrc), options: [depayloader: RTP.G711.Depayloader])
        |> child(:audio_decoder, G711.Decoder)
        |> get_child(:tee)
        |> via_out(:master)
        |> child(:audio_player, Membrane.PortAudio.Sink),
        get_child(:tee)
        |> via_out(:copy)
        |> child(:serializer, Membrane.WAV.Serializer)
        |> child(:file_sink_wav, %Sink{location: output_file})
      ], stream_sync: :sinks}

    [spec: spec]
  end

end
