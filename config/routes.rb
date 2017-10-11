Erp::Periods::Engine.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    namespace :backend, module: "backend", path: "backend/periods" do
      resources :periods do
        collection do
          post 'list'
					get 'dataselect'
          put 'set_active'
          put 'set_deleted'
          put 'set_active_all'
          put 'set_deleted_all'
        end
      end
    end
  end
end