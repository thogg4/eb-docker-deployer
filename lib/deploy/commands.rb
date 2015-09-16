require 'deploy/utility'

module Deploy
  module Commands
    include Deploy::Utility

    def build_image(repo, tag)
      shout "Building Docker Image: #{repo}:#{tag}"
      command = "docker build -t #{repo}:#{tag} ."
      exit(1) unless system(command)
    end

    def create_deploy_zip_file
      shout "Creating deploy.zip"
      command = "uploadStash=`git stash create`; git archive -o deploy.zip ${uploadStash:-HEAD}"
      exit(1) unless system(command)
    end

    def use_tag_in_dockerrun(repo, tag)
      shout "Changing Dockerrun.aws.json to contain latest tag"
      command = "sed 's/<TAG>/#{tag}/' < Dockerrun.aws.json.template > Dockerrun.aws.json"
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
