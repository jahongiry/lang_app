module Api
  module V1
    class TranslationsController < ApplicationController
      before_action :set_media_item
      before_action :set_translation, only: [:show, :update, :destroy]

      def index
        @translations = @media_item.translations
        render json: @translations
      end

      def show
        render json: @translation
      end

# POST /api/v1/media_items/:media_item_id/translations
def create
  # Find any existing translation and destroy it if it exists
  existing_translation = @media_item.translations.first
  existing_translation&.destroy

  # Create a new translation with the new data
  @translation = @media_item.translations.new(translation_params)

  if @translation.save
    render json: @translation, status: :created
  else
    render json: @translation.errors, status: :unprocessable_entity
  end
end


      def update
        if @translation.update(translation_params)
          render json: @translation
        else
          render json: @translation.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @translation.destroy
      end

      private

      def set_media_item
        @media_item = MediaItem.find(params[:media_item_id])
      end

      def set_translation
        @translation = @media_item.translations.find(params[:id])
      end

      def translation_params
        params.require(:translation).permit(:other_attributes).tap do |whitelisted|
          whitelisted[:array_of_objects] = params[:translation][:array_of_objects].map(&:to_unsafe_h) if params[:translation][:array_of_objects]
        end
      end


    end
  end
end
