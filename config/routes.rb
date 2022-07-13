Rails.application.routes.draw do
  get "/", to: "bts#index"
  get "/show", to: "bts#show"
end
