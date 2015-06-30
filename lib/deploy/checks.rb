require 'deploy/utility'

module Deploy
  module Checks
    include Deploy::Utility

    def check_setup
      (shout('docker not installed'); exit(1)) unless command?('docker')
      (shout('eb command not installed'); exit(1)) unless command?('eb')
      (shout('elasticbeanstalk not configured for this project. run "eb init".'); exit(1)) unless File.exist?('.elasticbeanstalk')
      (shout('AWS credentials not configured.'); exit(1)) unless ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY'] && ENV['AWS_REGION']
      (shout('ENV DOCKER_REPO not set'); exit(1)) unless ENV['DOCKER_REPO']
    end

    def check_rollback_version(version, environment)
      check_version(version, environment)
      (shout('You can only rollback to a previous version'); exit(1)) unless application_versions_array.include?(version)
    end

    def check_version(version, environment)
      (shout('You must pass a version with -v'); exit(1)) unless version
      (shout('You are currently on that version'); exit(1)) if current_version_for_environment(environment) == version
    end

  end
end
