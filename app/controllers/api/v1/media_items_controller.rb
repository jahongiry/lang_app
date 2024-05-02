module Api
  module V1
    class MediaItemsController < ApplicationController
      before_action :set_lesson
      before_action :set_media_item, only: [:show, :update, :destroy]

      def index
        @media_items = @lesson.media_items.map do |media_item|
          {
            id: media_item.id,
            lesson_id: media_item.lesson_id,
            media_type: media_item.media_type,
            media_link: url_for(media_item.media_link), 
            created_at: media_item.created_at,
            updated_at: media_item.updated_at
          }
        end
        render json: @media_items
      end

      # GET /api/v1/lessons/:lesson_id/media_items/:id
      def show
        @media_item = {
          id: @media_item.id,
          lesson_id: @media_item.lesson_id,
          media_type: @media_item.media_type,
          media_link: url_for(@media_item.media_link), 
          created_at: @media_item.created_at,
          updated_at: @media_item.updated_at
        }
        render json: @media_item
      end

     # POST /api/v1/lessons/:lesson_id/media_items
      def create
        if params[:media_item][:media_type] == 'link'
          # If it's a link, simply save it without processing
          @media_item = @lesson.media_items.build(media_type: 'link', media_link: params[:media_item][:media_link])
        elsif params[:media_item][:media_type] == 'image'
          # If it's an image, extract the uploaded file
          uploaded_file = params[:media_item][:media_link]

          # Save the uploaded file and store its URL in media_link
          if uploaded_file
            @media_item = @lesson.media_items.build(media_type: 'image')
            @media_item.media_link = save_uploaded_file(uploaded_file)
          else
            render json: { error: 'Image file is required' }, status: :unprocessable_entity
            return
          end
        else
          render json: { error: 'Invalid media type' }, status: :unprocessable_entity
          return
        end

        if @media_item.save
          render json: @media_item, status: :created
        else
          render json: @media_item.errors, status: :unprocessable_entity
        end
      end


      def save_uploaded_file(uploaded_file)
        # Generate a unique filename for the uploaded file
        filename = "#{SecureRandom.hex(10)}_#{uploaded_file.original_filename}"

        # Specify the directory where you want to save the uploaded files
        upload_directory = Rails.root.join('public', 'uploads')

        # Ensure that the directory exists, otherwise create it
        FileUtils.mkdir_p(upload_directory) unless File.directory?(upload_directory)

        # Build the full path to save the file
        file_path = File.join(upload_directory, filename)

        # Write the uploaded file to the specified path
        File.open(file_path, 'wb') do |file|
          file.write(uploaded_file.read)
        end

        # Return the URL of the saved file
        "/uploads/#{filename}"
      end

      # PATCH/PUT /api/v1/lessons/:lesson_id/media_items/:id
      def update
        if @media_item.update(media_item_params)
          render json: @media_item
        else
          render json: @media_item.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/lessons/:lesson_id/media_items/:id
      def destroy
        @media_item.destroy
        head :no_content
      end

      private

      def set_lesson
        @lesson = Lesson.find(params[:lesson_id])
      end

      def set_media_item
        @media_item = @lesson.media_items.find(params[:id])
      end

      def media_item_params
        params.require(:media_item).permit(:media_type, :media_link, :lesson_id)
      end
    end
  end
end