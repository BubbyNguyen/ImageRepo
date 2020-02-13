class PhotoController < ApplicationController

  #required libraries
  require 'open-uri'
  require 'dotenv'
  require 'aws-sdk'

  #Load ENV file with AWS credentials
  Dotenv.load

  #Set OpenURI Buffer to always use/return a StringIO instance by setting limit to 0KB
  OpenURI::Buffer.send :remove_const, 'StringMax'
  OpenURI::Buffer.const_set 'StringMax', 0

  #Pass through all photos in SQLite3 DB when loading homepage using Post model
  def index
    @posts = Post.all
  end

  #When POST upload request is received
  def upload
    #Cloudinary has more built in functions for media than s3 such as options for cropping, optimizing, etc
    @status = Cloudinary::Uploader.upload(params[:image])

    # After upload put it into the DB table where name is URL and caption is a description
    @post = Post.new({:name => @status['secure_url'], :caption => params[:caption]})
    if @post.save

      #If successfully saved then trigger Pusher
      #Pusher allows realtime update when images are uploaded (if another instance of the page is open)
      Pusher.trigger('posts-channel','new-post', {
          name: @post.name,
          caption: @post.caption
      })
    end
    #After upload go back to homepage
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Photo was successfully uploaded.' }
      format.json { head :no_content }
    end
  end

  #When GET show request is received
  def show
    #Pass through required params to load image
    @post = Post.find(params[:id])

    #Run image through AWS Rekognition engine and get results
    client = Aws::Rekognition::Client.new
    @resp = client.detect_labels(
        image: { bytes: File.read(open(@post.name))}
    )
  end

  #When DELETE photo request is received
  def destroy
    #If all is passed through as the param then delete everything
    if params[:id] == "all"
      @posts = Post.all
      @posts.each do |post|
        Cloudinary::Uploader.destroy(post.name)
        post.destroy
      end
    else
      #Else delete only the single photo
      @post = Post.find(params[:id])
      Cloudinary::Uploader.destroy(@post.name)
      @post.destroy
    end
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Photo was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  #When GET photo/download is request received download file to computer
  def download
    @post = Post.find(params[:id])
    data = open(@post.name)
    send_data data.read, filename: @post.caption, type: "image", disposition: 'attachment'
  end

end
