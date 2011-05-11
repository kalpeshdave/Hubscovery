class Github
  include HTTParty
  base_uri 'https://github.com/api/v2/json'

  class << self
    def repositories(terms, options = {})
      terms = terms.split(/\s+/).join("+")
      options = {
        :watchers  => 6,
        :forks     => 2,
        :pushed_at => "2w"
      }.merge!(options)
      repo_url = "/repos/search/#{terms}"
      results = get(repo_url).parsed_response["repositories"]
      if results
        results = if options[:watchers] >= 0
                    results.select { |r| r["watchers"] >= options[:watchers] }
                  else
                    results.select { |r| r["watchers"] <= options[:watchers] }
                  end
      end
      if results
        results = if options[:forks] >= 0
                    results.select { |r| r["forks"] >= options[:forks] }
                  else
                    results.select { |r| r["forks"] <= options[:forks] }
                  end
        results.sort { |a,b| b["pushed_at"] <=> a["pushed_at"] }
      end
    end
  end
end
