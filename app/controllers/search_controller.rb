class SearchController < ApplicationController
  def index
    @options = {}
    terms = params[:terms]
    watchers_regexp = /w:(\d+)/i
    forks_regexp = /f:(\d+)/i

    if watchers_regexp.match(terms)
      @options[:watchers] = watchers_regexp.match(terms)[1].to_i
      terms = terms.gsub(watchers_regexp, '')
    end

    if forks_regexp.match(terms)
      @options[:forks] = forks_regexp.match(terms)[1].to_i
      terms = terms.gsub(forks_regexp, '')
    end

    @original_terms = params[:terms]
    @repositories = Github.repositories(terms, @options) if params[:terms]
  end
end
