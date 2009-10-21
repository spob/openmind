require 'net/http'

url = '/releases/check_for_updates?releases=ABC2,102,103,98'
#url = '/releases/check_for_updates?releases=102'
Net::HTTP.start('localhost', 3000) do |http|
  response = http.get(url, 'Accept' => 'text/xml')

  puts "Code: #{response.code}" 
  puts "Message: #{response.message}"
  puts "Body:\n #{response.body}"
end