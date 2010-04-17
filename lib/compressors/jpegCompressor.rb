class JpegCompressor < Compressor
  def initialize
    super(['jpeg','jpg'])
    set_command(:jpegtran,'%executable% -copy none -optimize -outfile %output% %input%')
  end
end
