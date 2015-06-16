module Deploy
  class Deployer < Thor
    include Deploy::Output

    desc 'setup config', 'setup config'
    def setup
      (shout('AWS creds already configured at ~/.aws/config.'); exit(1)) if File.exist?(File.expand_path('~/.aws/config'))

      key = ask('Enter AWS Key:')
      secret = ask('Enter AWS Secret:')

      Dir.mkdir(File.expand_path('~/.aws'))

      File.open(File.expand_path('~/.aws/config'), 'w') do |f|
        f.puts '[default]'
        f.puts "aws_access_key_id = #{key}"
        f.puts "aws_secret_access_key = #{secret}"
      end
      shout('AWS creds successfully configured at ~/.aws/config.') if File.exist?(File.expand_path('~/.aws/config'))
    end

    method_option :version, aliases: '-v', desc: 'Version'
    method_option :environment, aliases: '-e', desc: 'Environment'
    method_option :build, aliases: '-b', desc: 'Build Image'
    desc 'deploy', 'deploy'
    def deploy
      check_setup

      environment = options[:environment]
      build = options[:build]

      version = options[:version]
      (shout('You must pass a version with -v'); exit(1)) unless version

      repo = ENV['DOCKER_REPO']

      if build
        announce({ color: '#6080C0', title: "Deployment started with build", text: "Deploying version #{version} to #{environment || 'stage'}" })
        build_image(repo, version)

        tag_image_as_latest(repo, version)

        push_image(repo, version)
        push_image(repo, 'latest')
      else
        announce({ color: '#6080C0', title: "Deployment started without build", text: "Deploying version #{version} to #{environment || 'stage'}" })
      end

      run_deploy(version, environment)
      announce({ color: 'good', title: 'Deployment Succeeded!!', text: "The current version of #{environment || 'stage'} is #{version}" })
    end

    method_option :version, aliases: '-v', desc: 'Version'
    method_option :environment, aliases: '-e', desc: 'Environment'
    desc 'rollback', 'rollback'
    def rollback
      check_setup

      environment = options[:environment]
      version = options[:version]
      (shout('You must pass a version with -v'); exit(1)) unless version

      repo = ENV['DOCKER_REPO']

      announce({ color: '#6080C0', title: "Rollback started", text: "Rolling back to #{version} on #{environment || 'stage'}" })

      pull_image(repo, version)

      tag_image_as_latest(repo, version)

      push_image(repo, 'latest')

      run_rollback(version, environment)
      announce({ color: 'good', title: 'Rollback Succeeded!!', text: "The current version of #{environment || 'stage'} is #{version}" })
    end

    desc 'send test notification', 'send test notification'
    def test_slack
      notifier('', { color: 'good', title: 'This is a test notification from eb-docker-deploy.' })
    end

    no_commands do

      def announce(attachments)
        shout("#{attachments[:title]} - #{attachments[:text]}")
        notifier('', attachments)
      end

      def notifier(message, attachments)
        if ENV['SLACK_WEBHOOK']
          @notifier ||= Slack::Notifier.new(ENV['SLACK_WEBHOOK'])
          @notifier.ping(message, {
            attachments: [attachments]
          })
        else
          shout 'You can send deployment notifications if you set the SLACK_WEBHOOK environment variable.'
        end
      end

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

      def pull_image(repo, tag)
        shout "Pulling Docker Image: #{repo}:#{tag}"
        command = "docker pull #{repo}:#{tag}"
        exit(1) unless system(command)
      end

      def run_deploy(version, environment=nil)
        command = environment ? "eb deploy #{environment} --label #{version}" : "eb deploy --label #{version}"
        shout "deploying #{version} to elastic beanstalk with command: #{command}"
        exit(1) unless system(command)
      end

      def run_rollback(version, environment=nil)
        command = environment ? "eb deploy #{environment} --version #{version}" : "eb deploy --version #{version}"
        shout "deploying #{version} to elastic beanstalk with command: #{command}"
        exit(1) unless system(command)
      end

      def check_setup
        (shout('docker not installed'); exit(1)) unless command?('docker')
        (shout('eb command not installed'); exit(1)) unless command?('eb')
        (shout('elasticbeanstalk not configured for this project. run "eb init".'); exit(1)) unless File.exist?('.elasticbeanstalk')
        (shout('AWS credentials not configured.'); exit(1)) unless File.exist?(File.expand_path('~/.aws/config'))
        (shout('ENV DOCKER_REPO not set'); exit(1)) unless ENV['DOCKER_REPO']
      end

      def command?(command)
        system("which #{command} > /dev/null 2>&1")
      end

    end

  end
end
