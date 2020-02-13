Rails.application.routes.draw do
  root 'photo#index'

  #Create custom routes for uploading and downloading
  get 'photo/download'
  post 'photo/upload'

  #Creates common routes for photo controller:
  resources :photo

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
