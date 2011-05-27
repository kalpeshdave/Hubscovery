class SearchController < ApplicationController
  def index
    @options = {}
    @original_terms = params[:terms]

    terms = params[:terms]
    parameters = {
      :watchers => /w:(\d+)/i,
      :forks => /f:(\d+)/i,
      :pushed_at => /p:(\d+)/i,
      :sort => /s:(\w+)/i,
      :language => /l:(\w+)/i,
      :force => /(--force)/i
    }

    parameters.each do |k,v|
      if v.match(terms)
        @options[k] = v.match(terms)[1]
        terms = terms.gsub(v, '')
      end
    end

    @options.delete(:sort) unless %w(pushed_at score watchers forks).include? @options[:sort]
    @options.delete(:language) unless Github::LANGUAGES.keys.include? @options[:language]

    @repositories = Github.repositories(terms, @options) if params[:terms]
  end
end
