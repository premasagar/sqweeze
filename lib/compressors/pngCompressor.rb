class PngCompressor < Compressor
   
  def initialize
    super('png')
    set_command(:pngcrush,'%executable% %input% %output%')
  end
 
end


