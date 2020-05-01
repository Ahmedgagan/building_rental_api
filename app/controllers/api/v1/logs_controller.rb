module Api
  module V1
    class LogsController < ApplicationController
      def index
        logs = Log.order('created_at DESC')
        render json: {status: '1', msg: 'All logs displayed', data:logs}, status: :ok
      end
    end
  end
end