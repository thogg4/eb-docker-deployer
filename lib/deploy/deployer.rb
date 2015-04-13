module Deploy
  class Deployer < Thor
    include Deploy::Output

    desc 'setup eb', 'setup eb'
    def setup
      command = "eb init"
      system(command)
    end

    method_option :version, aliases: '-v', desc: 'Version'
    desc 'deploy', 'deploy'
    def deploy
      check_setup

      version = options[:version]
      repo = ENV['DOCKER_REPO']
      
      shout "Building Docker Image: #{repo}:#{version}"
      command = "docker build -t #{repo}:#{version} ."
      system(command)

      shout "Tagging #{version} Docker Image"
      command = "docker tag -f #{repo}:#{version} #{repo}:latest"
      system(command)

      shout "Pushing Docker Image: #{repo}:#{version}"
      command = "docker push #{repo}:#{version}"
      system(command)
      shout "Pushing Docker Image: #{repo}:latest"
      command = "docker push #{repo}:latest"
      system(command)

      command = "eb deploy --label #{version}"
      system(command)
    end

    method_option :version, aliases: '-v', desc: 'Version'
    desc 'rollback', 'rollback'
    def rollback
      version = options[:version]
      repo = ENV['DOCKER_REPO']

      shout "Tagging #{version} Docker Image"
      command = "docker tag -f #{repo}:#{version} #{repo}:latest"
      system(command)

      shout "Pushing Docker Image: #{repo}:latest"
      command = "docker push #{repo}:latest"
      system(command)

      command = "eb deploy --version #{version}"
      system(command)
    end

    no_commands do

      def check_setup
        raise StandardError, 'docker not installed' unless command?('docker')
        raise StandardError, 'eb command not installed' unless command?('eb')
        raise StandardError, 'elasticbeanstalk not configured' unless File.exist?('.elasticbeanstalk')
        raise StandardError, 'Env DOCKER_REPO not set' unless ENV['DOCKER_REPO']
      end

      def command?(command)
        system("which #{command} > /dev/null 2>&1")
      end

    end

  end
end
