module SpreeOrderStatusTracking::Spree::OrdersControllerDecorator

  def status

  end

  def status_check
    if params[:email].blank?
      @orders = nil
    elsif params[:email].include? "@"
      @orders = ::Spree::Order.includes(:shipments)
                   .where(email: params[:email], state: :complete).order(id: :desc).limit(3)
    else
      @orders = ::Spree::Order.includes(:shipments)
                   .where(number: params[:email], state: :complete).order(id: :desc).limit(3)
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


  def status_timeline
    if params[:token].blank?
      redirect_to order_status_page_url
    else
      @order = ::Spree::Order.includes(:shipments)
                .where(token: params[:token]).first

      if @order.completed?
        @events = {
          submitted: { description: "Order Submitted" }, 
          packing: { description: "Order is being packed" },
          partial_shipped: { description: "Package Partially Shipped" },
          shipped: { description: "Package Shipped" },
          in_transit: { description: "In Transit" },
          delivered: { description: "Package Delivered" }
        }

        @events[:submitted][:record_time] = @order.completed_at

        # if @order.paid?
        #   @events[:paid][:record_time] = @order.approved_at
        # end

        if @order.approved?
          @events[:packing][:record_time] = @order.approved_at
        end

        if @order.shipped?
          shipments = []
          shipped_times = []
          @order.shipments.each do |shipment|
            shipments << {tracking: shipment.tracking, shipped_at: shipment.shipped_at, carrier: shipment.carrier, state: shipment.state, manifest: shipment.manifest}
            shipped_times << shipment.shipped_at if shipment.shipped_at.present?
          end

          if @order.shipment_state == "partial"
            @events[:partial_shipped][:shipments] = shipments
            @events[:partial_shipped][:record_time] = shipped_times.sort.first
          elsif @order.shipment_state == "shipped"
            @events[:shipped][:shipments] = shipments
            @events[:shipped][:record_time] = shipped_times.sort.last
          end
        end

        render 'spree/orders/status_timeline'
      else 
        redirect_to spree.cart_path
      end
    end
  end

end

Spree::OrdersController.prepend SpreeOrderStatusTracking::Spree::OrdersControllerDecorator
