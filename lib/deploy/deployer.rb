module Deploy
  class Deployer < Thor
    include Deploy::Output

    desc 'setup config', 'setup config'
    def setup
      command = 'eb init'
      system(command)
    end

    method_option :version, aliases: '-v', desc: 'Version'
    method_option :build, aliases: '-b', desc: 'Build Image'
    desc 'deploy', 'deploy'
    def deploy
      check_setup

      build = options[:build]

      version = options[:version]
      (shout('You must pass a version with -v'); exit(1)) unless version

      repo = ENV['DOCKER_REPO']
      
      if build
        build_image(repo, version)

        tag_image_as_latest(repo, version)

        push_image(repo, version)
        push_image(repo, 'latest')
      end

      run_deploy(version)
    end

    method_option :version, aliases: '-v', desc: 'Version'
    desc 'rollback', 'rollback'
    def rollback
      version = options[:version]
      (shout('You must pass a version with -v'); exit(1)) unless version

      repo = ENV['DOCKER_REPO']

      tag_image_as_latest(repo, version)

      push_image(repo, 'latest')

      run_deploy(version)
    end

    no_commands do

      def build_image(repo, tag)
        shout "Building Docker Image: #{repo}:#{tag}"
        command = "docker build -t #{repo}:#{tag} ."
        exit(1) unless system(command)
      end

      def tag_image_as_latest(repo, tag)
        shout "Tagging #{tag} Docker Image as Latest"
        command = "docker tag -f #{repo}:#{tag} #{repo}:latest"
        exit(1) unless system(command)
      end

      def push_image(repo, tag)
        shout "Pushing Docker Image: #{repo}:#{tag}"
        command = "docker push #{repo}:#{tag}"
        exit(1) unless system(command)
      end

      def run_deploy(version)
        command = "eb deploy --label #{version}"
        exit(1) unless system(command)
      end

      def save_version(version)
        #config_file['current_version'] = version
      end

      def config_file
        #UserConfig.new('.eb-deploy')['versions']
      end

      def check_setup
        (shout('docker not installed'); exit(1)) unless command?('docker')
        (shout('eb command not installed'); exit(1)) unless command?('eb')
        (shout('elasticbeanstalk not configured. run setup command'); exit(1)) unless File.exist?('.elasticbeanstalk')
        (shout('aws credentials not configured.'); exit(1)) unless File.exist?(File.expand_path('~/.aws/config'))
        (shout('ENV DOCKER_REPO not set'); exit(1)) unless ENV['DOCKER_REPO']
      end

      def command?(command)
        system("which #{command} > /dev/null 2>&1")
      end

    end

  end
end
