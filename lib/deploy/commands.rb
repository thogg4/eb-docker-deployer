require 'deploy/utility'

module Deploy
  module Commands
    include Deploy::Utility

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

    def run_deploy(version, environment)
      command = "eb deploy #{environment} --label #{version}"
      shout "deploying #{version} to elastic beanstalk with command: #{command}"
      exit(1) unless system(command)
    end

    def run_rollback(version, environment)
      command = "eb deploy #{environment} --version #{version}"
      shout "deploying #{version} to elastic beanstalk with command: #{command}"
      exit(1) unless system(command)
    end

  end
end
