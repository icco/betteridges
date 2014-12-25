require 'net/http'
require 'uri'
require 'json'
require 'set'

# Shhhh it's a secret.
API_KEY = "a844021009f05833323dc50060c06646:6:57284525"

def query_nyt_headlines(word, file)
  # http://developer.nytimes.com/docs/read/article_search_api_v2
  # TODO(icco): Switch to https.
  # NOTE: 10 Calls per second and 10,000 Calls per day
  i = 0
  (0..10).each do |page|
    uri = URI("http://api.nytimes.com/svc/search/v2/articlesearch.json")
    params = {
      :fl => "web_url,headline",
      :sort => "newest",
      :fq => "headline:(\"#{word}\")",
      :page => page,
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
    puts data["meta"]
    filtered = data["docs"].map {|entry| {url: entry["web_url"], headline: entry["headline"]["main"]} }.delete_if {|entry| !/\?$/.match(entry[:headline]) }

    # So ugly.
    s = Set.new(JSON.parse(File.read(file)))
    s.merge(filtered)
    File.open(file, "w") do |f|
      f.write(s.to_a.to_json)
    end
  end
end

query_nyt_headlines "Can", "headlines.json"
