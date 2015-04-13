require 'thor'

class Deploy < Thor

  method_option :version, aliases: '-v', desc: 'Version'
  desc 'deploy', 'deploy'
  def deploy
    puts options  
  end

end
