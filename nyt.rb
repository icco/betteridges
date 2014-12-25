require 'net/http'
require 'uri'
require 'json'

# Shhhh it's a secret.
API_KEY = "a844021009f05833323dc50060c06646:6:57284525"

def query_nyt_headlines(word)
  # http://developer.nytimes.com/docs/read/article_search_api_v2
  # TODO(icco): Switch to https.
  # NOTE: 10 Calls per second and 10,000 Calls per day
  uri = URI("http://api.nytimes.com/svc/search/v2/articlesearch.json")
  params = {
    :fl => "web_url,headline",
    :sort => "newest",
    :fq => "headline:(\"#{word}\")",
    :"api-key" => API_KEY,
  }
  uri.query = URI.encode_www_form(params)
  p uri

  res = Net::HTTP.start(uri.host, uri.port, :use_ssl => false) do |http|
    request = Net::HTTP::Get.new uri
    response = http.request request # Net::HTTPResponse object
  end

  if res.code != "200"
    raise "Error getting data (#{res.code}): #{res.body}"
  end

  data = JSON.parse(res.body)["response"]
  return data["docs"].map {|entry| {url: entry["web_url"], headline: entry["headline"]["main"]} }.delete_if {|entry| !/\?$/.match(entry[:headline]) }
end

answer = query_nyt_headlines "Can"
puts JSON.pretty_generate(answer)
