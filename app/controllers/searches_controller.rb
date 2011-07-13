class SearchesController < ApplicationController
  def new
    @search = Search.new
    @original_terms = params[:q]

    query = params[:q]
    terms, @options = prepare_terms_and_options(query)
    @repositories = Github.repositories(terms, @options) if query
  end

  def show
    @search = Search.find_by_permalink(params[:link])
    @original_terms = @search.q

    query = @search.q
    terms, @options = prepare_terms_and_options(query)
    @repositories = Github.repositories(terms, @options) if query
    render :template => "searches/new"
  end

  def create
    @search = Search.create!(:q => params[:q])
    redirect_to "/perma/#{@search.permalink}"
  end

  protected
  def prepare_terms_and_options(terms, options = {})
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
        options[k] = v.match(terms)[1]
        terms = terms.gsub(v, '')
      end
    end

    if options
      options.delete(:sort) unless %w(pushed_at score watchers forks).include? options[:sort]
      options.delete(:language) unless Github::LANGUAGES.keys.include? options[:language]
    end
    [terms, options]
  end
end
