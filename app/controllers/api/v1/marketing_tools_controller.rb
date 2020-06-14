module Api
  module V1
    class MarketingToolsController < ApplicationController
      def getAllFiles
        a = Dir["public/marketing-tools/"+params[:folder_name]+params[:file_name].to_s+"/*"]
        if a.length < 1
          a = Dir["public/marketing-tools/"+params[:folder_name]+"/*"]
        end
        if a.length < 1
          a = Dir["public/marketing-tools/*"]
        end
        if a.length < 1
          a = Dir["public/*"]
        end
        render json: {status: '1', msg: 'Marketing tools', data:a}, status: :ok
      end

      def file
        if params[:folder_name] && params[:file_name]
          path = "public/marketing-tools/"+params[:folder_name]+"/"+params[:file_name]
          if File.exist?(path)
            send_file path, disposition: 'download'
          else
            render json: {status: '0', msg: 'File not found'}, status: :ok
          end
        else
          render json: {status: '0', msg: 'Required parameters not found'}, status: :ok
        end
      end
    end
  end
end