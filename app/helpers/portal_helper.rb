module PortalHelper
  def serial_number_link serial_number_str, serial_number
    if current_user.can_specify_email_in_portal? && serial_number && serial_number.releases
      link_to serial_number_str, show_serial_number_portal_path(serial_number)
    else
      serial_number_str
    end
  end
end
