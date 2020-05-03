module Api
  module V1
    class LogsController < ApplicationController
      def index
        logs = Log.joins("INNER JOIN users b on log.admin_user_id=b.user_id").select("*").order('created_at DESC')
        render json: {status: '1', msg: 'All logs displayed', data:logs}, status: :ok
      end
    end
  end
end