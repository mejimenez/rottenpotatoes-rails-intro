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
    unless params[ :sort_by ].nil?
      sort_collection
    end
  end
  
  def sort_collection
    v = params[:sort_by].to_s
    class_selector = "@h" + v + " = true"
    eval(class_selector)
    @movies = @movies.sort{ |f, s| eval("f.#{v}") <=> eval("s.#{v}") }
  end
  
  def populate_checked_ratings
    if( params[ :ratings ].nil? and session[ :ratings ].nil? )
      @checked_ratings = {}
      Movie.all_ratings.each do |rating|
        @checked_ratings[rating] = 1
      end
    elsif !params[ :ratings ].nil?
      @checked_ratings = params[:ratings] 
    else
      @checked_ratings = session[ :ratings ]
    end
    session[ :ratings ] = @checked_ratings
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
end
