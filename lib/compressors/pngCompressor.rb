class PngCompressor < Compressor
   
  def initialize
    super('png')
    set_command(:pngcrush,'%executable% -q -rem text %input% %output%')

  end
 
end


