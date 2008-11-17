# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

class CsvUtils
    # this is required if you want this to work with IE
  def self.setup_request_for_csv headers, request, filename
    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers["Content-type"] = "text/plain" 
      headers['Cache-Control'] = 'private'
      headers['Content-Disposition'] = "attachment; filename=\"#{filename}\"" 
      headers['Expires'] = "0" 
    else
      headers["Content-Type"] ||= 'text/csv'
      headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" 
    end
  end
end
