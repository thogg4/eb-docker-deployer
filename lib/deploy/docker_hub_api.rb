module DockerHubApi

  ROOT_PATH = 'https://registry.hub.docker.com'

  def get(url)
    body = RestClient.get("#{ROOT_PATH}#{url}", { Authorization: "Basic dGhvZ2c0OnlhbmtlZXNxMQ==" }).body
    JSON.parse(body)
  end

end
