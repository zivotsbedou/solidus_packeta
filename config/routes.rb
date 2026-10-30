# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  if SolidusSupport.backend_available?
    namespace :admin do
      resources :shipments, only: [] do
        resource :packeta_label, only: [:create, :show]
      end
    end
  end
end
