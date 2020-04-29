module Api
  module V1
    class BookingDetailsController < ApplicationController

      def index
        boking_details = BookingDetail.joins("INNER JOIN unit_details b on booking_details.unit_id=b.id").select('booking_details.id as booking_id ,*').where('is_booked=true')
        render json: {status: '1', msg: 'All booking details Loaded', data: boking_details}, status: :ok
      end

      def show
        booking_details = BookingDetail.joins("INNER JOIN unit_details b on booking_details.unit_id=b.id").select('booking_details.id as booking_id ,*').where('is_booked=true AND booking_details.id=?',params[:id]);
        render json: {status: '1', msg: 'Booking detail Loaded', data: booking_details[0]}, status: :ok
      end

      def create
        file = params[:payment_receipt]
        params[:payment_receipt]= name = file.original_filename
        p params[:payment_receipt]
        path = File.expand_path("../../../../assets/",__FILE__)
        Dir.mkdir(path+'/'+params[:booked_by_user_id]) unless Dir.exist?(path+'/'+params[:booked_by_user_id])
        path = path+"/"+params[:booked_by_user_id]+"/"+name
        unit_details = UnitDetail.find(params[:unit_id])
        unless unit_details.is_booked && unit_details.unit_availability=='Available'
          unless File.exist?(path)
            File.open(path, "wb") do |f|
              f.write(File.read(file))
              if File.exist?(path)
                booking_detail = BookingDetail.new(booking_details_params)
                unit_details.update(:is_booked=>true)
                if booking_detail.save
                  render json: {status: '1', msg: 'saved booking details',data:booking_detail}, status: :ok
                else
                  render json: {status: '0', msg: 'Booking details not saved',data:booking_detail.error}, status: :ok
                end
              else
                render json: {status: '0', msg: 'booking receipt not saved',}, status: :ok  
              end
            end
          else
            render json: {status: '0', msg: 'booking receipt not saved because receipt already exists', data: {'error':'File Already Exists'}}, status: :ok  
          end
        else
          render json: {status: '0', msg: 'this unit is already booked', data: {'error':'unit Already booked'}}, status: :ok  
        end
      end

      def destroy
        booking_detail = BookingDetail.find(params[:id]);
        if booking_detail.update(booking_details_params)
          render json: {status: '1', msg: 'Booking details Deleted', data: booking_detail}, status: :ok
        else
          render json: {status: '0', msg: 'Booking detail not Deleted', data: booking_detail.error}, status: :ok
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
                if booking_detail.update(booking_details_params)
                  render json: {status: '1', msg: 'Booking details Updated', data: booking_detail}, status: :ok
                else
                  render json: {status: '0', msg: 'Booking detail not Updated', data: booking_detail.error}, status: :ok
                end
              else
                render json: {status: '0', msg: 'booking receipt not saved',}, status: :ok  
              end
            end
          else
            render json: {status: '0', msg: 'booking receipt not saved because receipt already exists', data: {'error':'File Already Exists'}}, status: :ok  
          end
        else
          booking_detail = BookingDetail.find(params[:id]);
          if booking_detail.update(booking_details_params)
            render json: {status: '1', msg: 'Booking details Updated', data: booking_detail}, status: :ok
          else
            render json: {status: '0', msg: 'Booking detail not Updated', data: booking_detail.error}, status: :ok
          end
        end
      end

      def image
        p params[:name]
        p File.expand_path("../../../../assets/"+params[:id]+"/"+params[:name],__FILE__)
        path = File.expand_path("../../../../assets/"+params[:id]+"/"+params[:name],__FILE__)
        send_file path, disposition: 'download'
      end

      def bookings
        bookings = BookingDetail.where("booked_by_user_id=? AND booking_details.is_active=true AND booking_details."+'"SPA_signed"'+"=true AND booking_details.booking_confirmation=true",params[:id]).joins("INNER JOIN unit_details b on booking_details.unit_id=b.id").select('booking_details.id as booking_id ,*')
        render json: {status: '1', msg: 'Booking details of Agent', data: bookings}, status: :ok
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
          :remark,
          :handover,
          :disbursement
        );
      end
    end
  end
end