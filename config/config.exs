import Config

if config_env() == :test do
  config :ogp,
    req_options: [
      plug: {Req.Test, MyStub},
      retry: false
    ]
end
