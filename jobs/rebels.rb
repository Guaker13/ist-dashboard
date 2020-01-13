require 'byebug'
require 'rest-client'
require './lib/countries'

SCHEDULER.every '60s' do
  items = []

  COUNTRIES.each do |country|
    stats = fetch_stats(country)
    items << { label: country[:name], value: stats['total'] }
  end

  send_event('rebels', items: items)
end

def fetch_stats(country)
  url = country[:rm_api_url] + '/api/private/stats'
  response = RestClient.get(url, {
    'Authorization' => "Basic #{compute_basic_auth(country)}"
  })

  JSON.parse(response.body)
end

def compute_basic_auth(country)
  username_key = country[:iso_code] + '_AUTH_USERNAME'
  password_key = country[:iso_code] + '_AUTH_PASSWORD'

  Base64.encode64("#{ENV.fetch(username_key)}:#{ENV.fetch(password_key)}")
end
