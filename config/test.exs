use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :materia_career, MateriaCareerWeb.Test.Endpoint,
  http: [port: 4001],
  # server: false,
  debug_errors: true,
  code_reloader: false,
  check_origin: false,
  watchers: []

# Print only warnings and errors during test
config :logger, level: :info

# Configure your database
config :materia_career, MateriaCareer.Test.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "materia_career_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :materia_career, repo: MateriaCareer.Test.Repo

# Configures GuardianDB
config :guardian, Guardian.DB,
  repo: MateriaCareer.Test.Repo,
  # default
  schema_name: "guardian_tokens",
  # token_types: ["refresh_token"], # store all token types if not set
  # default: 60 minutes
  sweep_interval: 60

# mail settings
config :materia, Materia.Mails.MailClient, client_module: Materia.Mails.MailClientSendGrid

config :sendgrid, api_key: System.get_env("SENDGRID_API_KEY") || ""

config :materia, Materia.Accounts,
  system_from_email: "materia@karabiner.tech",
  # not effect when use Materia.Mails.MailClientAwsSes
  system_from_name: "MateriaCarrer運用チーム",
  # user_registration_request_mail_template_type: "user_registration_request",
  # user_registration_url: "psn.analyzine.com/#/signup",
  user_registration_completed_mail_template_type: "user_registration_completed",
  sign_in_url: "psn.analyzine.com/#/signin",
  password_reset_request_mail_template_type: "password_reset_request",
  password_reset_url: "psn.analyzine.com/#/reset",
  password_reset_completed_mail_template_type: "password_reset_completed"

config :materia, MateriaCareer.Offer,
  system_from_email: "materia@karabiner.tech",
  system_from_name: "MateriaCarrer運用チーム",
  entry_template_type: "new_entry",
  offer_template_type: "new_offer"
