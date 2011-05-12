class SearchController < ApplicationController
  def index
    @options = {}
    terms = params[:terms]
    watchers_regexp = /w:(\d+)/i
    forks_regexp = /f:(\d+)/i
    pushed_at_regexp = /p:(\d+)/i
    sort_regexp = /s:(\w+)/i

    if watchers_regexp.match(terms)
      @options[:watchers] = watchers_regexp.match(terms)[1].to_i
      terms = terms.gsub(watchers_regexp, '')
    end

    if forks_regexp.match(terms)
      @options[:forks] = forks_regexp.match(terms)[1].to_i
      terms = terms.gsub(forks_regexp, '')
    end

    if pushed_at_regexp.match(terms)
      @options[:pushed_at] = pushed_at_regexp.match(terms)[1].to_i
      terms = terms.gsub(pushed_at_regexp, '')
    end

    if sort_regexp.match(terms)
      term = sort_regexp.match(terms)[1]
      @options[:sort] = term.to_sym if %w(pushed_at score watchers forks).include? term
      terms = terms.gsub(sort_regexp, '')
    end

    @original_terms = params[:terms]
    @repositories = Github.repositories(terms, @options) if params[:terms]
  end
end
