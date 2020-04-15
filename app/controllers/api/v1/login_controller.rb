module Api 
  module V1
    class LoginController < ApplicationController
      def signup
        user = User.new(user_params)
        if user.save
          if params[:user_type]=="AGENT"
            agentDetail = AgentDetail.new(user_id:user.id,REN:params[:REN],SPA_signed:params[:SPA_signed])
            if agentDetail.save
              render json: {status: '1', msg: 'saved user and agent details'}, status: :ok
            else
              render json: {status: '0', msg: 'Saved department', data: agentDetail.errors}, status: :unprocessable_entity
            end
          end
          render json: {status: '1', msg: 'Saved User'}, status: :ok
        else
          render json: {status: '0', msg: 'User not saved', data: user.errors}, status: :unprocessable_entity  
        end
      end

      def userLogin
        login = User.where("email=? AND password=? AND is_active=1",params[:email],params[:password])
        if login.length>0
          if(login[0].user_type!="ADMIN")
            login = User.where("email=? AND password=? AND is_active=1",params[:email],params[:password]).joins("INNER JOIN agent_details b on users.id = b.user_id").select("*")
          end
          render json: {status: '1', msg: 'Login Successful', data:login}, status: :ok
        else
          email = User.where("email=?",params[:email])
          if email.length>0
            render json: {status: '0', msg: 'Incorrect Password'}, status: :unprocessable_entity  
          else
            render json: {status: '0', msg: 'Email not found'}, status: :unprocessable_entity  
          end
        end
      end

      def removeUser
        user = User.find(params[:id])
        if user.update_attributes(params.permit(:is_active))
          render json: {status: '1', msg: 'user deleted', data: user}, status: :ok
        else
          render json: {status: '0', msg: 'user not deleted', data: user.errors}, status: :unprocessable_entity  
        end
      end

      def updateUser
        user = User.find(params[:id])
        type = ""
        if user.update_attributes(user_params)
          type = user.user_type
        end
        if type=="AGENT"
          agent = AgentDetail.where("user_id=?",params[:id]).joins("INNER JOIN users b on agent_details.user_id = b.id").select("*")
          if agent[0].update_attributes(agent_params)
            render json: {status: '1', msg: 'user updated', data: agent[0]}, status: :ok
          else
            render json: {status: '0', msg: 'user not updated', data: agent[0].errors}, status: :unprocessable_entity  
          end
        elsif type=="ADMIN"
          render json: {status: '1', msg: 'user updated', data: user}, status: :ok
        else
          render json: {status: '0', msg: 'user not updated', data: user.errors}, status: :unprocessable_entity  
        end
      end

      

      private
      def user_params
        params.permit(
          :name,
          :password,
          :user_type,
          :contact,
          :email,
          :is_active
        )
      end
      def agent_params
        params.permit(
          :REN,
          :SPA_signed
        )
      end
    end
  end
end