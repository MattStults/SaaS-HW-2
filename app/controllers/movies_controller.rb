class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index_validate_params? params
    session[:ratings] = params[:ratings] if !params[:ratings].nil?
    session[:sortBy] = params[:sortBy] if !params[:sortBy].nil?
    session[:ratings] = [] if session[:ratings].nil?
    session[:sortBy] = "none" if session[:sortBy].nil?
    !(params[:ratings].nil? || params[:sortBy].nil?)
  end

  def index
    unless index_validate_params? params
      flash.keep
      redirect_to(movies_path( 
        :ratings => session[:ratings], 
        :sortBy => session[:sortBy]))
    end

    if params[:ratings] != nil
      if params[:ratings].respond_to? :keys
        @ratings_shown = params[:ratings].keys
      else
        @ratings_shown = params[:ratings]
      end
    else
      @ratings_shown = []
    end

    @all_ratings = Movie.ratings
    @sortBy = params[:sortBy]
    if @sortBy == 'release_date'
      order = "release_date"
    elsif @sortBy == 'title'
      order = "title"
    else
      order = "id"
    end
    direction = params[:direction]
    if direction == "DESC"
      order += " DESC"
    else
      order += " ASC"
    end
    @movies = Movie.find :all, :order => order, :conditions => {:rating => @ratings_shown} 
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
