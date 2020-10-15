module SpreeOrderStatusTracking::Spree::OrdersControllerDecorator

  def status

  end

  def status_check
    if params[:order_id].blank? or params[:email].blank?
      @order = nil
    else
      @order = ::Spree::Order.includes(line_items: [variant: [:option_values, :images, :product]], bill_address: :state, ship_address: :state)
                   .find_by(number: params[:order_id])

      if @order.email.casecmp(params[:email]) != 0
        @order = nil
      end
    end


    respond_to do |format|
      if @order.nil?
        @error = 'Sorry, no related order found.'
      else
        @error = ''
      end
      format.js { render 'spree/orders/status_check' }
    end

  end

end

Spree::OrdersController.prepend SpreeOrderStatusTracking::Spree::OrdersControllerDecorator
