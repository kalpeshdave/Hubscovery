class Github
  include HTTParty
  base_uri 'https://github.com/api/v2/json'

  LANGUAGES = {
    "as3" => "ActionScript",
    "c" => "C",
    "csharp" => "C#",
    "cpp" => "C++",
    "css" => "CSS",
    "common-lisp" => "Common Lisp",
    "diff" => "Diff",
    "erlang" => "Erlang",
    "html" => "HTML",
    "haskell" => "Haskell",
    "java" => "Java",
    "javascript" => "JavaScript",
    "lua" => "Lua",
    "objective-c" => "Objective-C",
    "php" => "PHP",
    "perl" => "Perl",
    "python" => "Python",
    "ruby" => "Ruby",
    "sql" => "SQL",
    "scala" => "Scala",
    "scheme" => "Scheme",
    "tex" => "TeX",
    "xml" => "XML"
  }

  class << self
    def repositories(terms, options = {})
      dc = Dalli::Client.new
      options = {
        :watchers  => 6,
        :forks     => 2,
        :pushed_at => 26,
        :sort => :score
      }.merge!(options)

      all_results = []
      search_terms = terms.split(/\s+/)

      search_terms.each do |term|
        cached = dc.get(term)
        unless cached
          repo_url = "/repos/search/#{term}"
          raw = get(repo_url)
          cached = raw.parsed_response["repositories"]
          dc.set(term, cached)
        end
        all_results << cached
      end

      all_results.flatten!

      if all_results.count > 0
        if search_terms.count > 1
          result_counts = Hash.new {0}
          all_results.each { |h| result_counts[h["name"]] += 1 }
          intersected = result_counts.select! { |r| result_counts[r] == search_terms.count }.keys
          results = all_results.flatten.select! { |h| intersected.include? h["name"] }.uniq { |h| h["name"] }
        else
          results = all_results.flatten
        end
      end

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
      end

      if results
        results = results.select { |r| r["language"] == LANGUAGES[options[:language]] } if options[:language]
      end

      if results
        results = if options[:pushed_at] >= 0
                    results.select { |r| DateTime.parse(r["pushed_at"]) >= options[:pushed_at].weeks.ago }
                  else
                    results.select { |r| DateTime.parse(r["pushed_at"]) <= options[:pushed_at].weeks.ago }
                  end
      end

      results.sort { |a,b| b[options[:sort].to_s] <=> a[options[:sort].to_s] } if results
    end
  end
end
