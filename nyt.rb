require 'net/http'
require 'uri'

# Shhhh it's a secret.
API_KEY = "a844021009f05833323dc50060c06646:6:57284525"

# http://developer.nytimes.com/docs/read/article_search_api_v2
uri = URI("http://api.nytimes.com/svc/search/v2/articlesearch")
params = {
  :"api-key" => API_KEY,
  :"response-format" => "json",
  :fl => "web_url,headline",
  :q => "?",
  :sort => "newest",
}
uri.query = URI.encode_www_form(params)
p Net::HTTP.get(uri)
