module Deploy
  module Utility

    def command?(command)
      system("which #{command} > /dev/null 2>&1")
    end

  end
end
