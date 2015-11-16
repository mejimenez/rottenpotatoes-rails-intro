class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    populate_checked_ratings
    @movies = []
    @checked_ratings.each do |rating|
      @movies << Movie.where( rating: rating).to_a
    end
    @movies.flatten!
  end
  
  def populate_checked_ratings
    if params[ :ratings ].nil?
      @checked_ratings = {}
      Movie.all_ratings.each do |rating|
        @checked_ratings[rating] = 1
      end
    else
      @checked_ratings = params[:ratings] 
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
  def sort_by_title
    @movies = Movie.order(:title)
    @htitle = true
    render action: "index"
  end
  
  def sort_by_rating
    @movies = Movie.order(:rating)
    @hrating = true
    render action: "index"
  end
  
  def sort_by_release
    @movies = Movie.order(:release_date)
    @hrelease = true
    render action: "index"
  end
end
