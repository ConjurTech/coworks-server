Rails.application.routes.draw do
  resources :brands
  resources :tags
  resources :categories
  resources :companies

  namespace :admin do
    DashboardManifest::DASHBOARDS.each do |dashboard_resource|
      resources dashboard_resource
    end

    root controller: DashboardManifest::ROOT_DASHBOARD, action: :index
  end

  mount_devise_token_auth_for 'User', at: 'auth'

  root to: 'application#test'
end
