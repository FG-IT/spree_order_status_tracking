module SpreeOrderStatusTracking::Spree::OrdersControllerDecorator

  def status

  end

  def status_check
    if params[:email].blank?
      @orders = nil
    else
      @orders = ::Spree::Order.includes(:shipments)
                   .where(email: params[:email]).order(id: :desc).limit(3)
    end

    respond_to do |format|
      if @orders.blank?
        @error = 'Sorry, no related order found, please check whether email information is correct.'
      else
        @error = ''
      end
      format.js { render 'spree/orders/status_check' }
    end

  end

end

Spree::OrdersController.prepend SpreeOrderStatusTracking::Spree::OrdersControllerDecorator
