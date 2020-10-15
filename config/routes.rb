Spree::Core::Engine.add_routes do
  get '/order-status' => 'orders#status', as: :order_status_page
  post '/order-status' => 'orders#status_check'
end
