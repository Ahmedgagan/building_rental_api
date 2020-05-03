module Api
  module V1
    class BookingDetailsController < ApplicationController

      def index
        boking_details = BookingDetail.joins("INNER JOIN unit_details b on booking_details.unit_id=b.id").select('booking_details.id as booking_id ,*').where('is_booked=true and is_active=true')
        render json: {status: '1', msg: 'All booking details Loaded', data: boking_details}, status: :ok
      end

      def show
        booking_details = BookingDetail.joins("INNER JOIN unit_details b on booking_details.unit_id=b.id").select('booking_details.id as booking_id ,*').where('booking_details.id=?',params[:id])
        render json: {status: '1', msg: 'Booking detail Loaded', data: booking_details[0]}, status: :ok
      end

      def create
        file = params[:payment_receipt]
        params[:payment_receipt]= name = file.original_filename
        p params[:payment_receipt]
        path = File.expand_path("../../../../assets/",__FILE__)
        Dir.mkdir(path+'/'+params[:booked_by_user_id]) unless Dir.exist?(path+'/'+params[:booked_by_user_id])
        p Dir[path]
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
                  user = User.find(booking_detail[:booked_by_user_id])
                  action = "New booking of unit: "+unit_details[:unit_type]+" done by "+user[:name]
                  log = Log.new(:unit_number=>unit_details[:unit_number], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :remark=>"New Booking")
                  log.save
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
        booking_detail = BookingDetail.find(params[:id])
        if booking_detail.update(:is_active=>false, :remark=>params[:remark])
          unit_details = UnitDetail.find(booking_detail[:unit_id])
          if unit_details.update(:is_booked=>false)
            user = User.find(params[:admin_user_id])
            action = "Booking of unit: "+unit_details[:unit_type]+" canceled by "+user[:name]
            log = Log.new(:unit_number=>unit_details[:unit_number], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :admin_user_id=>params[:admin_user_id],:remark=>params[:remark])
            log.save
            render json: {status: '1', msg: 'Booking details Deleted', data: booking_detail}, status: :ok
          else
            render json: {status: '0', msg: 'Booking details Deleted but unit details is_active not set', data: unit_details.error}, status: :ok
          end
        else
          render json: {status: '0', msg: 'Booking detail not Deleted', data: booking_detail.error}, status: :ok
        end
      end

      def update
        booking_detail = BookingDetail.find(params[:id])
        if params[:payment_receipt]
          file = params[:payment_receipt]
          p file.class
          params[:payment_receipt]= file.original_filename
          name = file.original_filename
          p params[:payment_receipt]
          path = File.expand_path("../../../../assets/",__FILE__)
          File.delete(path+booking_detail.booked_by_user_id+"/"+booking_detail.payment_receipt) if File.exist?(path+booking_detail[:booked_by_user_id].to_s+"/"+booking_detail[:payment_receipt])
          Dir.mkdir(path+'/'+params[:booked_by_user_id].to_s) unless Dir.exist?(path+'/'+params[:booked_by_user_id].to_s)
          path = path+"/"+params[:booked_by_user_id].to_s+"/"+name
          unless File.exist?(path)
            File.open(path, "wb") do |f|
              f.write(File.read(file))
              if File.exist?(path)
                if booking_detail.update(booking_details_params)
                  unit_details = UnitDetail.find(booking_detail[:unit_id])
                  user = User.find(booking_detail[:booked_by_user_id])
                  p params
                  if params[:booking_confirmation] != nil
                    p "ghusa"
                    action = nil
                    if params[:booking_confirmation] == true
                      action = "Booking confirmed of "+unit_details[:unit_type]+" by "+booking_detail[:booked_by_user_id].to_s
                    else
                      action = "Booking cancelled of "+unit_details[:unit_type]+" by "+user[:name]
                    end
                    log = Log.new(:unit_number=>unit_details[:unit_number], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :remark=>"Booking Confirmation Updated")
                    log.save
                  end
                  if params[:SPA_signed] != nil
                    p "ghusa spa"
                    action = nil
                    if params[:SPA_signed] == true
                      action = "SPA signed of "+unit_details[:unit_type]+" by "+booking_detail[:booked_by_user_id].to_s
                    else
                      action = "SPA Unsigned of "+unit_details[:unit_type]+" by "+user[:name]
                    end
                    log = Log.new(:unit_number=>unit_details[:unit_number], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :remark=>"SPA Signed Updated")
                    log.save
                  end
                  if params[:disbursement] != nil
                    p "ghusa dis"
                    action = nil
                    if params[:disbursement] == true
                      action = "disbursment done of "+unit_details[:unit_type]+" by "+booking_detail[:booked_by_user_id].to_s
                    else
                      action = "disbursment not done of "+unit_details[:unit_type]+" by "+user[:name]
                    end
                    log = Log.new(:unit_number=>unit_details[:unit_number], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :remark=>"Disbursment details Updated")
                    log.save
                  end
                  if params[:handover] != nil
                    p "ghusa hand"
                    action = nil
                    if params[:handover] == true
                      action = "handover done of "+unit_details[:unit_type]+" by "+booking_detail[:booked_by_user_id].to_s
                    else
                      action = "handover not done of "+unit_details[:unit_type]+" by "+user[:name]
                    end
                    log = Log.new(:unit_number=>unit_details[:unit_number], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :remark=>"Handover details Updated")
                    log.save
                  end
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
          booking_detail = BookingDetail.find(params[:id])
          if booking_detail.update(booking_details_params)
            unit_details = UnitDetail.find(booking_detail[:unit_id])
            user = User.find(booking_detail[:booked_by_user_id])
            p params
            if params[:booking_confirmation] != nil
              p "ghusa"
              action = nil
              if params[:booking_confirmation] == true
                action = "Booking confirmed of "+unit_details[:unit_type]+" by "+booking_detail[:booked_by_user_id].to_s
              else
                action = "Booking cancelled of "+unit_details[:unit_type]+" by "+user[:name]
              end
              log = Log.new(:unit_number=>unit_details[:unit_number], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :remark=>"Booking Confirmation Updated")
              log.save
            end
            if params[:SPA_signed] != nil
              p "ghusa spa"
              action = nil
              if params[:SPA_signed] == true
                action = "SPA signed of "+unit_details[:unit_type]+" by "+booking_detail[:booked_by_user_id].to_s
              else
                action = "SPA Unsigned of "+unit_details[:unit_type]+" by "+user[:name]
              end
              log = Log.new(:unit_number=>unit_details[:unit_number], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :remark=>"SPA Signed Updated")
              log.save
            end
            if params[:disbursement] != nil
              p "ghusa dis"
              action = nil
              if params[:disbursement] == true
                action = "disbursment done of "+unit_details[:unit_type]+" by "+booking_detail[:booked_by_user_id].to_s
              else
                action = "disbursment not done of "+unit_details[:unit_type]+" by "+user[:name]
              end
              log = Log.new(:unit_number=>unit_details[:unit_number], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :remark=>"Disbursment details Updated")
              log.save
            end
            if params[:handover] != nil
              p "ghusa hand"
              action = nil
              if params[:handover] == true
                action = "handover done of "+unit_details[:unit_type]+" by "+booking_detail[:booked_by_user_id].to_s
              else
                action = "handover not done of "+unit_details[:unit_type]+" by "+user[:name]
              end
              log = Log.new(:unit_number=>unit_details[:unit_number], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :remark=>"Handover details Updated")
              log.save
            end
            render json: {status: '1', msg: 'Booking details Updated', data: booking_detail}, status: :ok
          else
            render json: {status: '0', msg: 'Booking detail not Updated', data: booking_detail.error}, status: :ok
          end
        end
      end

      def image
        if params[:name] && params[:id]
          path = "app/assets/"+params[:id]+"/"+params[:name]
          if File.exist?(path)
            send_file path, disposition: 'download'
          else
            render json: {status: '0', msg: 'File not found'}, status: :ok
          end
        else
          render json: {status: '0', msg: 'Required parameters not found'}, status: :ok
        end
      end

      def bookings
        bookings = BookingDetail.where("booked_by_user_id=?",params[:id]).joins("INNER JOIN unit_details b on booking_details.unit_id=b.id").select('booking_details.id as booking_id ,*')
        render json: {status: '1', msg: 'Booking details of Agent', data: bookings}, status: :ok
      end

      def getAllFiles
        a = Dir["app/assets/"+params[:id].to_s+"/*"]
        render json: {status: '1', msg: 'Booking details of Agent', data:a}, status: :ok
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
        )
      end
    end
  end
end