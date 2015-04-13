module Deploy
  module Output

    def shout(message)
      message_size = message.size
      if message_size < 77
        # lines are always 80 characters
        stars = '*' * (77 - message_size)
        puts(green("+ ") + "#{message} #{green(stars)}")
      else
        puts(green('+ ') + message)
      end
    end

    def red(message)
      colorize(31, message)
    end

    def green(message)
      colorize(32, message)
    end

    def yellow(message)
      colorize(33, message)
    end

    def pink(message)
      colorize(35, message)
    end

    def colorize(color_code, message)
      "\e[#{color_code}m#{message}\e[0m"
    end

  end
end

