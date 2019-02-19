defmodule MateriaCareerWeb.Router do
  use MateriaCareerWeb, :router

  #pipeline :browser do
  #  plug :accepts, ["html"]
  #  plug :fetch_session
  #  plug :fetch_flash
  #  plug :protect_from_forgery
  #  plug :put_secure_browser_headers
  #end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :guardian_auth do
    plug Materia.UserAuthPipeline
  end

  pipeline :guardian_auth_acount do
    plug Materia.AccountAuthPipeline
  end

  pipeline :tmp_user_auth do
    plug Materia.UserRegistrationAuthPipeline
  end

  pipeline :pw_reset_auth do
    plug Materia.PasswordResetAuthPipeline
  end

  pipeline :grant_check do
    repo = Application.get_env(:materia, :repo)
    plug Materia.Plug.GrantChecker, repo: repo
  end

  scope "/api", MateriaWeb do
    pipe_through :api

    post "sign-in", AuthenticatorController, :sign_in
    post "refresh", AuthenticatorController, :refresh
    post "tmp-registration", UserController, :registration_tmp_user
    post "request-password-reset", UserController, :request_password_reset

  end

  scope "/api", MateriaCareerWeb do
    pipe_through [ :api, :guardian_auth]
    # projects
    post "/list-my-projects", ProjectController, :list_my_projects
    post "/create-my-project", ProjectController, :create_my_project
    post "/update-my-project", ProjectController, :update_my_project
    
    # offers
    get "/list-my-offers", OfferController, :list_my_offers
    post "/list-my-projects-offers", OfferController, :list_my_projects_offers
    post "/create-my-organization-offer", OfferController, :create_my_organization_offer
    post "/create-my-offer", OfferController, :create_my_offer
    post "/update-my-organization-offer", OfferController, :update_my_organization_offer
    post "/update-my-offer", OfferController, :update_my_offer
    post "/answer-offer-to-my-organization", OfferController, :answer_offer_to_my_organization
    post "/answer-offer-to-me", OfferController, :answer_offer_to_me

    # records
    get "/list-my-records", RecordController, :list_my_records
    post "/create-my-record", RecordController, :create_my_record
    post "/update-my-record", RecordController, :update_my_record

    # skills
    get "/list-my-skills", SkillController, :list_my_skills
    post "/create-my-skill", SkillController, :create_my_skill
    post "/create-my-skills", SkillController, :create_my_skills
    put "/update-my-skill", SkillController, :update_my_skill
    delete "/delete-my-skill", SkillController, :delete_my_skill
  end

  scope "/api", MateriaCareerWeb do
    pipe_through [ :api]
    resources "/projects", ProjectController, except: [:new, :edit]
    resources "/tags", TagController, except: [:new, :edit]
    resources "/records", RecordController, except: [:new, :edit]
    resources "/offers", OfferController, except: [:new, :edit]
    resources "/skill", SkillController, except: [:new, :edit]

  end

  scope "/api", MateriaWeb do
    pipe_through [ :api, :tmp_user_auth]

    get "varidation-tmp-user", AuthenticatorController, :is_varid_token
    post "user-registration", UserController, :registration_user
    post "user-registration-and-sign-in", UserController, :registration_user_and_sign_in

  end

  scope "/api", MateriaWeb do
    pipe_through [ :api, :pw_reset_auth]

    get "varidation-pw-reset", AuthenticatorController, :is_varid_token
    post "reset-my-password", UserController, :reset_my_password

  end

  scope "/api", MateriaWeb do
    pipe_through [ :api, :guardian_auth]

    get "/user", UserController, :show_me
    post "/grant", GrantController, :get_by_role
    post "sign-out", AuthenticatorController, :sign_out
    get "auth-check", AuthenticatorController, :is_authenticated
    post "search-users", UserController, :list_users_by_params
    resources "/addresses", AddressController, except: [:new, :edit]
    post "create-my-addres", AddressController, :create_my_address

  end

  scope "/api/ops", MateriaWeb do
    pipe_through [ :api, :guardian_auth, :grant_check]

    resources "/grants", GrantController, except: [:new, :edit]
    resources "/mail-templates", MailTemplateController, except: [:new, :edit]

    resources "/users", UserController, except: [:edit, :new]
    resources "/organizations", OrganizationController, except: [:new, :edit]

  end


end
