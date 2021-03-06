class PlaylistsController < ApplicationController
  # GET /playlists
  # GET /playlists.json
  def index
    @playlists = Playlist.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @playlists }
    end
  end

  # GET /playlists/1
  # GET //playlists.json
  def show
    @playlist = Playlist.find(params[:id])
    @tracks = @playlist.tracks
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @playlist }
    end
  end

  # GET /playlists/new
  # GET /playlists/new.json
  def new
    @playlist = Playlist.new
    
      respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @playlist }
    end
  end

  # GET /playlists/1/edit
  def edit
    @playlist = Playlist.find(params[:id])
  end

  # POST /playlists
  # POST /playlists.json
  def create    
    # create playlist with title, and related feeds with feed_urls
    @playlist = Playlist.new(params[:playlist])
    Rails.logger.debug"params hash is #{params.to_yaml}"    
    respond_to do |format|
    if @playlist.save
      # call workers on each feed, which again will call workers on each post
      @playlist.feeds.each do |feed|
        Rails.logger.debug"called FeedWorker for feed #{feed.id}"
        FeedWorker.perform_async(feed.id)
      end
      # and send the user to a blank page that starts polling for tracks coming in.
      format.html { redirect_to @playlist, notice: 'Playlist was successfully created.' }
      format.json { render json: @playlist, status: :created, location: @playlist }
    else
        format.html { render action: "new" }
        format.json { render json: @playlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # FIXME handle update playlist
  # PUT /playlists/1
  # PUT /playlists/1.json
  def update
    @playlist = Playlist.find(params[:id])

    respond_to do |format|
      if @playlist.update_attributes(params[:playlist])
        format.html { redirect_to @playlist, notice: 'Playlist was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @playlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /playlists/1
  # DELETE /playlists/1.json
  def destroy
    @playlist = Playlist.find(params[:id])
    @playlist.destroy

    respond_to do |format|
      format.html { redirect_to playlists_url }
      format.json { head :no_content }
    end
  end

end