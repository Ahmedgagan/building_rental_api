module Api
  module V1
    class BookingDetailsController < ApplicationController

      def index
        boking_details = BookingDetail.order('created_at DESC').where("is_active=1 AND SPA_signed=1 AND booking_confirmation=1");
        render json: {status: '1', msg: 'All booking details Loaded', data: boking_details}, status: :ok
      end

      def show
        booking_details = BookingDetail.find(params[:id]);
        render json: {status: '1', msg: 'Booking detail Loaded', data: booking_details}, status: :ok
      end

      def create
        file = params[:payment_receipt]
        params[:payment_receipt]= name = file.original_filename
        p params[:payment_receipt]
        path = File.expand_path("../../../../assets/",__FILE__)
        Dir.mkdir(path+'/'+params[:booked_by_user_id]) unless Dir.exist?(path+'/'+params[:booked_by_user_id])
        path = path+"/"+params[:booked_by_user_id]+"/"+name
        unless File.exist?(path)
          File.open(path, "wb") do |f|
            f.write(File.read(file))
            if File.exist?(path)
              booking_detail = BookingDetail.new(booking_details_params)
              if booking_detail.save
                render json: {status: '1', msg: 'saved booking details',data:booking_detail}, status: :ok
              else
                render json: {status: '0', msg: 'Booking details not saved',data:booking_detail.error}, status: :unprocessable_entity
              end
            else
              render json: {status: '0', msg: 'booking receipt not saved',}, status: :unprocessable_entity  
            end
          end
        else
          render json: {status: '0', msg: 'booking receipt not saved because receipt already exists', data: {'error':'File Already Exists'}}, status: :unprocessable_entity  
        end
      end

      def destroy
        booking_detail = BookingDetail.find(params[:id]);
        if booking_detail.update(booking_details_params)
          render json: {status: '1', msg: 'Booking details Deleted', data: booking_detail}, status: :ok
        else
          render json: {status: '0', msg: 'Booking detail not Deleted', data: booking_detail.error}, status: :unprocessable_entity
        end
      end

      def update
        booking_detail = BookingDetail.find(params[:id]);
        if params[:payment_receipt]
          
          file = params[:payment_receipt]
          params[:payment_receipt]= name = file.original_filename
          p params[:payment_receipt]
          path = File.expand_path("../../../../assets/",__FILE__)
          File.delete(path+booking_detail.booked_by_user_id+"/"+booking_detail.payment_receipt) if File.exist?(path_to_file)
          Dir.mkdir(path+'/'+params[:booked_by_user_id]) unless Dir.exist?(path+'/'+params[:booked_by_user_id])
          path = path+"/"+params[:booked_by_user_id]+"/"+name
          unless File.exist?(path)
            File.open(path, "wb") do |f|
              f.write(File.read(file))
              if File.exist?(path)
                booking_detail = BookingDetail.new(booking_details_params)
                if booking_detail.save
                  render json: {status: '1', msg: 'saved booking details',data:booking_detail}, status: :ok
                else
                  render json: {status: '0', msg: 'Booking details not saved',data:booking_detail.error}, status: :unprocessable_entity
                end
              else
                render json: {status: '0', msg: 'booking receipt not saved',}, status: :unprocessable_entity  
              end
            end
          else
            render json: {status: '0', msg: 'booking receipt not saved because receipt already exists', data: {'error':'File Already Exists'}}, status: :unprocessable_entity  
          end
        end
        # if booking_detail.update(booking_details_params)
        #   render json: {status: '1', msg: 'Booking details Deleted', data: booking_detail}, status: :ok
        # else
        #   render json: {status: '0', msg: 'Booking detail not Deleted', data: booking_detail.error}, status: :unprocessable_entity
        # end
      end

      private

      def booking_details_params
        params.permit(
          :booked_by_user_id,
          :unit_number,
          :price,
          :name,
          :contact,
          :payment_receipt,
          :SPA_signed,
          :booking_confirmation,
          :is_active,
          :unit_id,
          :remark
        );
      end
    end
  end
end