module SpreeOrderStatusTracking::Spree::ShipmentDecorator
  def tracking_url
    @tracking_url ||= shipping_method&.build_tracking_url(tracking)
    return @tracking_url if @tracking_url.present?

    if tracking.present? && tracking.start_with?('https')
      @tracking_url = tracking
      return @tracking_url
    end

    if carrier.present?
      carrier_upper = carrier.upcase
      @tracking_url = if carrier_upper.include?('USPS')
          "https://tools.usps.com/go/TrackConfirmAction?qtc_tLabels1=#{tracking}"
        elsif carrier_upper.include?('UPS')
          "https://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=#{tracking}"
        elsif carrier_upper.include?('FEDEX')
          "https://www.fedex.com/fedextrack/?action=track&trackingnumber=#{tracking}"
        elsif carrier_upper.include?('DHL')
          "https://www.dhl.com/us-en/home/tracking.html?tracking-id=#{tracking}"
        end
    end
  end
end

::Spree::Shipment.prepend ::SpreeOrderStatusTracking::Spree::ShipmentDecorator
