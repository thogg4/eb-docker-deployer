require 'deploy/utility'

module Deploy
  module Versions
    include Deploy::Utility

    def eb
      Aws::ElasticBeanstalk::Client.new
    end

    def version_exists?(version)
      application_versions_array.include?(version)
    end

    def current_version_for_environment(environment)
      eb.describe_environments(environment_names: [environment]).environments.first.version_label
    end

    def application_versions_array
      @array ||= eb.describe_application_versions.application_versions.reverse.map(&:version_label)
    end

  end
end
