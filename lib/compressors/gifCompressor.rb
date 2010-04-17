class GifCompressor < Compressor
   
  def initialize
    super('gif')

    set_command(        
         :gifsicle, '%executable% --optimize < %input% > %output%'
    )
  end
 
end


