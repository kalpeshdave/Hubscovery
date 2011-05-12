class Github
  include HTTParty
  base_uri 'https://github.com/api/v2/json'

  class << self
    def repositories(terms, options = {})
      dc = Dalli::Client.new('localhost:11211')
      options = {
        :watchers  => 6,
        :forks     => 2,
        :pushed_at => "2w"
      }.merge!(options)
      all_results = []
      terms.split(/\s+/).each do |term|
        cached = dc.get(term)
        unless cached
          repo_url = "/repos/search/#{term}"
          cached = get(repo_url).parsed_response["repositories"]
          dc.set(term, cached)
        end
        all_results << cached
      end
      result_counts = Hash.new {0}
      all_results.flatten.each { |h| result_counts[h["name"]] += 1 }
      intersected = result_counts.select! { |r| result_counts[r] == all_results.count }.keys
      results = all_results.flatten.select! { |h| intersected.include? h["name"] }.uniq { |h| h["name"] }
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
