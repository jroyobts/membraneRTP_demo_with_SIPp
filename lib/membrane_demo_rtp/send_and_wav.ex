defmodule Membrane.Demo.RTP.ReceivePipeline_SIPp do
  use Membrane.Pipeline
  require Logger
  alias Membrane.{G711, RTP, UDP}
  alias Membrane.File.Sink
  #use BufferInspector


  @local_ip {127, 0, 0, 1}

  @impl true
  def handle_init(_ctx, opts) do
    %{audio_port_src1: audio_port_src1,
      audio_port_src2: audio_port_src2,
      audio_port_dst1: audio_port_dst1,
      audio_port_dst2: audio_port_dst2} = opts

    struct = [
      # Primera sesión RTP
      child(:rtp_session_1, %RTP.SessionBin{
        fmt_mapping: %{
          8 => {:G711, 64_000}, # G.711 PCMA/PCMU
          101 => {:telephone_event, 8_000} # DTMF eventos telefónicos
        }
      }),
      # Segunda sesión RTP
      child(:rtp_session_2, %RTP.SessionBin{
        fmt_mapping: %{
          8 => {:G711, 64_000}, # G.711 PCMA/PCMU
          101 => {:telephone_event, 8_000} # DTMF eventos telefónicos
        }
      }),

      # Fuente UDP para el primer puerto
      child(:audio_src_1, %UDP.Source{
        local_port_no: audio_port_src1,
        local_address: @local_ip
      }),


      # Fuente UDP para el segundo puerto
      child(:audio_src_2, %UDP.Source{
        local_port_no: audio_port_src2,
        local_address: @local_ip
      }),

      # Para mandar el audio
      child(:audio_sink_1, %UDP.Sink{
        destination_port_no: audio_port_dst1,
        destination_address: @local_ip
      }),

      child(:audio_sink_2, %UDP.Sink{
        destination_port_no: audio_port_dst2,
        destination_address: @local_ip
      }),

      # Elementos para paralelizar tareas
      child(:tee_1,Membrane.Tee.Master),
      child(:tee_2, Membrane.Tee.Master),

      # Reenvío de audio a destino
      get_child(:audio_src_1)
      |> get_child(:tee_1)
      |> via_out(:master)
      |> get_child(:audio_sink_1),

      # Procesado de sesión rtp
      get_child(:tee_1)
      |> via_out(:copy)
      |> via_in(:rtp_input)
      |> get_child(:rtp_session_1),

      # Reenvío de audio a destino
      get_child(:audio_src_2)
      |> get_child(:tee_2)
      |> via_out(:master)
      |> get_child(:audio_sink_2),

      # Procesado de sesión rtp
      get_child(:tee_2)
      |> via_out(:copy)
      |> via_in(:rtp_input)
      |> get_child(:rtp_session_2),


    ]


    {[spec: struct], %{}}
  end

  @impl true
  def handle_child_notification({:new_rtp_stream, ssrc, 8, _extensions}, :rtp_session_1, _ctx, state) do
    Logger.info("Detectado stream G.711 en sesión 1 con SSRC: #{inspect(ssrc)}")
    state = Map.put(state, :audio_ssrc_1, ssrc)
    actions = handle_stream(state)
    {actions, state}
  end

  @impl true
  # Esto quizás habría que tenerlo en cuenta también
  def handle_child_notification({:new_rtp_stream, ssrc, 101, _extensions}, :rtp_session_1, _ctx, state) do
    Logger.info("Detectado stream de eventos telefónicos (DTMF) en sesión 1 con SSRC: #{inspect(ssrc)}")
    {[], state}
  end
  @impl true
  def handle_child_notification({:new_rtp_stream, ssrc, 8, _extensions}, :rtp_session_2, _ctx, state) do
    Logger.info("Detectado stream G.711 en sesión 2 con SSRC: #{inspect(ssrc)}")
    state = Map.put(state, :audio_ssrc_2, ssrc)
    actions = handle_stream(state)
    {actions, state}
  end

  @impl true
  def handle_child_notification({:new_rtp_stream, ssrc, 101, _extensions}, :rtp_session_2, _ctx, state) do
    Logger.info("Detectado stream de eventos telefónicos (DTMF) en sesión 2 con SSRC: #{inspect(ssrc)}")
    {[], state}
  end

  @impl true
  def handle_child_notification({:new_rtp_stream, _ssrc, encoding_name, _extensions}, child_name, _ctx, _state)
      when child_name in [:rtp_session_1, :rtp_session_2] do
    raise "Codificación no soportada en #{child_name}: #{inspect(encoding_name)}"
  end

  @impl true
  def handle_child_notification({:connection_info, @local_ip, _port}, child_name, _ctx, state)
      when child_name in [:audio_src_1, :audio_src_2] do
    Logger.info("Fuente UDP #{child_name} conectada.")
    {[], state}
  end

  @impl true
  def handle_child_notification({:connection_info, {0,0,0,0},_port}, child_name, _ctx, state)
    when child_name in [:audio_sink_1, :audio_sink_2] do
    Logger.info("Conexión UDP establecida en #{inspect(child_name)}")
    {[], state}
  end

  #Cláusula catch-all para manejar otras notificaciones
  # @impl true
  # def handle_child_notification(notification, child_name, _ctx, state) do
  #   Logger.warn("Notificación no manejada de #{child_name}: #{inspect(notification)}")
  #   {[], state}
  # end

  defp handle_stream(%{audio_ssrc_1: ssrc1, audio_ssrc_2: ssrc2}) do
    spec = [
      child(:interleaver, %Membrane.AudioInterleaver{
        input_stream_format: %Membrane.RawAudio{
          channels: 1,
          sample_rate: 8_000,
          sample_format: :s16le
        },
        order: [:left, :right]
      }),
      get_child(:rtp_session_1)
      |> via_out(Pad.ref(:output, ssrc1), options: [depayloader: RTP.G711.Depayloader])
      |> child(:audio_decoder_1, G711.Decoder)
      |> via_in(Pad.ref(:input, :right))
      |> get_child(:interleaver),

      get_child(:rtp_session_2)
      |> via_out(Pad.ref(:output, ssrc2), options: [depayloader: RTP.G711.Depayloader])
      |> child(:audio_decoder_2, G711.Decoder)
      |> via_in(Pad.ref(:input, :left))
      |> get_child(:interleaver),


      get_child(:interleaver)
      |> child(:serializer, Membrane.WAV.Serializer)
      |> child(:file_sink_wav, %Sink{location: "output.wav"})

    ]

    [spec: spec]
  end

  defp handle_stream(_state) do
    []
  end
end
