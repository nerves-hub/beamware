use Mix.Config

config :nerves_hub_core, firmware_upload: NervesHubCore.Firmwares.Upload.File

config :nerves_hub_core, NervesHubCore.Firmwares.Upload.File,
  local_path: "/tmp/firmware",
  public_path: "/firmware"

# config :nerves_hub_core, NervesHubCore.Firmwares.Upload.S3, bucket: System.get_env("S3_BUCKET_NAME")

config :nerves_hub_core, NervesHubCore.Repo,
  adapter: Ecto.Adapters.Postgres,
  ssl: false

config :nerves_hub_core, NervesHubCore.CertificateAuthority,
  host: "0.0.0.0",
  port: 8443,
  ssl: [
    keyfile: Path.join([__DIR__, "../../../test/fixtures/cfssl/ca-client-key.pem"]),
    certfile: Path.join([__DIR__, "../../../test/fixtures/cfssl/ca-client.pem"]),
    cacertfile: Path.join([__DIR__, "../../../test/fixtures/cfssl/ca.pem"]),
    server_name_indication: 'ca.nerves-hub.org'
  ]
