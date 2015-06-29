module DockerHubApi

  ROOT_PATH = 'https://registry.hub.docker.com'

  def get(url)
    body = RestClient.get("#{ROOT_PATH}#{url}", { Authorization: "Basic #{get_token}" }).body
    JSON.parse(body)
  end

  def get_token
    auths_hash = JSON.parse(File.open(File.expand_path('~/.docker/config.json')).read)['auths']
    docker_hub_token = auths_hash['https://index.docker.io/v1/']['auth']
  end

end
