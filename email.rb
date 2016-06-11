module Email
  require 'mail'
  require 'yaml'
  def send_email(score)
    email = YAML.load_file("public/email.yml")
    addr = email["server"]["address"]
    acc = email["server"]["account"]
    psw = email["server"]["password"]
    recivers = email["client"]

    Mail.defaults do
      delivery_method :smtp,  address: addr,
                              port: 25,
                              user_name: acc,
                              password: psw,
                              enable_ssl: true
    end

    Mail.deliver do
      from     acc
      to       recivers.join(",")
      subject  'Here is the image you wanted'
      body     beatify(score)
    end
  end

  def beatify(scores)
    scores.join("\n")
  end

end
