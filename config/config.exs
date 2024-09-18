import Config

config :signaturit,
  api_key: ((System.get_env("SIGNATURIT_API_KEY", nil)) || "Missing env variable SIGNATURIT_API_KEY"),
  url: (System.get_env("SIGNATURIT_URL", nil) || raise "Missing env variable SIGNATURIT_URL")


#import_config "#{config_env()}.exs"
