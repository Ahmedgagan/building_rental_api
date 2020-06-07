module Api
  module V1
    class BookingDetailsController < ApplicationController

      def index
        boking_details = BookingDetail.joins("INNER JOIN unit_details b on booking_details.unit_id=b.id INNER JOIN users c on booking_details.booked_by_user_id=c.id").select('*, booking_details.id as booking_id, booking_details.name as customer_name , c.contact as agent_contact, booking_details.contact as booking_contact').where('is_booked=true and booking_details.is_active=true')
        render json: {status: '1', msg: 'All booking details Loaded', data: boking_details}, status: :ok
      end

      def show
        booking_details = BookingDetail.joins("INNER JOIN unit_details b on booking_details.unit_id=b.id INNER JOIN users c on booking_details.booked_by_user_id=c.id").select('*, booking_details.id as booking_id, booking_details.name as customer_name,  c.contact as agent_contact, booking_details.contact as booking_contact').where('booking_details.id=?',params[:id])
        render json: {status: '1', msg: 'Booking detail Loaded', data: booking_details[0]}, status: :ok
      end

      def unit_id_booking
        booking_details = BookingDetail.joins("INNER JOIN unit_details b on booking_details.unit_id=b.id INNER JOIN users c on booking_details.booked_by_user_id=c.id").select('*, booking_details.id as booking_id, booking_details.name as customer_name,  c.contact as agent_contact, booking_details.contact as booking_contact').where('b.id=? AND b.is_booked=true AND booking_details.is_active=true',params[:id])
        if booking_details && booking_details.length > 0
          render json: {status: '1', msg: 'Booking Detail Loaded', data: booking_details[0]}, status: :ok
        else
          render json: {status: '0', msg: 'Booking Detail Not Found'}, status: :ok
        end
      end

      def create
        booking_status = new_booking(params)
        if booking_status[1] == '1'
          render json: {status: booking_status[1], msg: booking_status[0], data:booking_status[2]}, status: :ok
        else
          render json: {status: booking_status[1], msg: booking_status[0], data:{'error':booking_status[0]}}, status: :ok
        end
        


        




        # unless unit_details.is_booked && unit_details.unit_availability=='Available'
        #   unless File.exist?(path)
        #     File.open(path, "wb") do |f|
        #       f.write(File.read(file))
        #       if File.exist?(path)
        #         booking_detail = BookingDetail.new(booking_details_params)
        #         unit_details.update(:is_booked=>true)
        #         if booking_detail.save
        #           user = User.find(booking_detail[:booked_by_user_id])
        #           action = "New booking of unit: "+unit_details[:unit_type]+" done by "+user[:name]
        #           log = Log.new(:unit_number=>unit_details[:unit_number], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :remark=>"New Booking", :admin_user_id=>params[:admin_user_id])
        #           log.save
        #           ## send notification
        #           reg_id = User.where("id!=?",user[:id]).select('token')
        #           registration_id = []
        #           reg_id.each{ |x| registration_id.push x[:token]}
        #           fcm_push_notification(action, registration_id, 'New Booking')
        #           render json: {status: '1', msg: 'saved booking details',data:booking_detail}, status: :ok
        #         else
        #           render json: {status: '0', msg: 'Booking details not saved',data:booking_detail.error}, status: :ok
        #         end
        #       else
        #         render json: {status: '0', msg: 'booking receipt not saved',}, status: :ok  
        #       end
        #     end
        #   else
        #     render json: {status: '0', msg: 'booking receipt not saved because receipt already exists', data: {'error':'File Already Exists'}}, status: :ok  
        #   end
        # else
        #   render json: {status: '0', msg: 'this unit is already booked', data: {'error':'unit Already booked'}}, status: :ok  
        # end
      end

      def destroy
        booking_detail = BookingDetail.find(params[:id])
        if booking_detail.update(:is_active=>false, :remark=>params[:remark])
          unit_details = UnitDetail.find(booking_detail[:unit_id])
          if unit_details.update(:is_booked=>false, :unit_availability=> "Available")
            user = User.find(params[:admin_user_id])
            action = "Booking of unit: "+unit_details[:unit_block]+"-"+unit_details[:unit_floor]+"-"+unit_details[:unit_number]+" canceled by "+user[:name]
            log = Log.new(:unit_number=>booking_detail[:id], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :admin_user_id=>params[:admin_user_id],:remark=>params[:remark])
            log.save
            ## send notification
            reg_id = User.where("id!=?",user[:id]).select('token')
            registration_id = []
            reg_id.each{ |x| registration_id.push x[:token]}
            fcm_push_notification(action, registration_id, 'Booking Canceled')
            render json: {status: '1', msg: 'Booking details Deleted', data: booking_detail}, status: :ok
          else
            render json: {status: '0', msg: 'Booking details Deleted but unit details is_active not set', data: unit_details.error}, status: :ok
          end
        else
          render json: {status: '0', msg: 'Booking detail not Deleted', data: booking_detail.error}, status: :ok
        end
      end

      def update
        p "params"
        p params
        receipt = nil
        if params[:payment_receipt]
          receipt = update_receipt(params)
          if receipt[1] == '0'
            render json: {status: receipt[1], msg: receipt[0], data: {'error':receipt[0]}}, status: :ok
            return
          end
        end

        update_details = update_booking(params)
        data = update_details[2] if update_details[2]
        data = {'error':update_details[0]} unless data
        render json: {status: update_details[1], msg: update_details[0], data: data}, status: :ok
        
        # booking_detail = BookingDetail.find(params[:id])
        # if params[:payment_receipt]
        #   file = params[:payment_receipt]
        #   p file.class
        #   params[:payment_receipt]= file.original_filename
        #   name = file.original_filename
        #   p params[:payment_receipt]
        #   path = File.expand_path("../../../../assets/",__FILE__)
        #   File.delete(path+booking_detail.booked_by_user_id+"/"+booking_detail.payment_receipt) if File.exist?(path+booking_detail[:booked_by_user_id].to_s+"/"+booking_detail[:payment_receipt])
        #   Dir.mkdir(path+'/'+params[:booked_by_user_id].to_s) unless Dir.exist?(path+'/'+params[:booked_by_user_id].to_s)
        #   path = path+"/"+params[:booked_by_user_id].to_s+"/"+name
        #   unless File.exist?(path)
        #     File.open(path, "wb") do |f|
        #       f.write(File.read(file))
        #       if File.exist?(path)
        #         if booking_detail.update(booking_details_params)
        #           unit_details = UnitDetail.find(booking_detail[:unit_id])
        #           user = User.find(booking_detail[:booked_by_user_id])
        #           p params
        #           if params[:booking_confirmation] != nil
        #             p "ghusa"
        #             action = nil
        #             if params[:booking_confirmation] == true
        #               action = "Booking confirmed of "+unit_details[:unit_type]+" by "+user[:name]
        #             else
        #               action = "Booking cancelled of "+unit_details[:unit_type]+" by "+user[:name]
        #             end
        #             log = Log.new(:unit_number=>unit_details[:unit_number], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :remark=>"Booking Confirmation Updated", :admin_user_id=>params[:admin_user_id])
        #             log.save
        #             ## send notification
        #             reg_id = User.where("id!=?",user[:id]).select('token')
        #             registration_id = []
        #             reg_id.each{ |x| registration_id.push x[:token]}
        #             fcm_push_notification(action, registration_id, 'Booking Confirmation Updated')
        #           end
        #           if params[:SPA_signed] != nil
        #             p "ghusa spa"
        #             action = nil
        #             if params[:SPA_signed] == true
        #               action = "SPA signed of "+unit_details[:unit_type]+" by "+user[:name]
        #             else
        #               action = "SPA Unsigned of "+unit_details[:unit_type]+" by "+user[:name]
        #             end
        #             log = Log.new(:unit_number=>unit_details[:unit_number], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :remark=>"SPA Signed Updated", :admin_user_id=>params[:admin_user_id])
        #             log.save
        #             ## send notification
        #             reg_id = User.where("id!=?",user[:id]).select('token')
        #             registration_id = []
        #             reg_id.each{ |x| registration_id.push x[:token]}
        #             fcm_push_notification(action, registration_id, 'SPA Signed Updated')
        #           end
        #           if params[:disbursement] != nil
        #             p "ghusa dis"
        #             action = nil
        #             if params[:disbursement] == true
        #               action = "disbursment done of "+unit_details[:unit_type]+" by "+user[:name]
        #             else
        #               action = "disbursment not done of "+unit_details[:unit_type]+" by "+user[:name]
        #             end
        #             log = Log.new(:unit_number=>unit_details[:unit_number], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :remark=>"Disbursment details Updated", :admin_user_id=>params[:admin_user_id])
        #             log.save
        #             ## send notification
        #             reg_id = User.where("id!=?",user[:id]).select('token')
        #             registration_id = []
        #             reg_id.each{ |x| registration_id.push x[:token]}
        #             fcm_push_notification(action, registration_id, 'Disbursement details Updated')
        #           end
        #           if params[:handover] != nil
        #             p "ghusa hand"
        #             action = nil
        #             if params[:handover] == true
        #               action = "handover done of "+unit_details[:unit_type]+" by "+user[:name]
        #             else
        #               action = "handover not done of "+unit_details[:unit_type]+" by "+user[:name]
        #             end
        #             log = Log.new(:unit_number=>unit_details[:unit_number], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :remark=>"Handover details Updated", :admin_user_id=>params[:admin_user_id])
        #             log.save
        #             ## send notification
        #             reg_id = User.where("id!=?",user[:id]).select('token')
        #             registration_id = []
        #             reg_id.each{ |x| registration_id.push x[:token]}
        #             fcm_push_notification(action, registration_id, 'Handover Details Updated')
        #           end
        #           render json: {status: '1', msg: 'Booking details Updated', data: booking_detail}, status: :ok
        #         else
        #           render json: {status: '0', msg: 'Booking detail not Updated', data: booking_detail.error}, status: :ok
        #         end
        #       else
        #         render json: {status: '0', msg: 'booking receipt not saved',}, status: :ok  
        #       end
        #     end
        #   else
        #     render json: {status: '0', msg: 'booking receipt not saved because receipt already exists', data: {'error':'File Already Exists'}}, status: :ok  
        #   end
        # else
        #   booking_detail = BookingDetail.find(params[:id])
        #   if booking_detail.update(booking_details_params)
        #     unit_details = UnitDetail.find(booking_detail[:unit_id])
        #     user = User.find(booking_detail[:booked_by_user_id])
        #     p params
        #     if params[:booking_confirmation] != nil
        #       p "ghusa"
        #       action = nil
        #       if params[:booking_confirmation] == true
        #         action = "Booking confirmed of "+unit_details[:unit_type]+" by "+user[:name]
        #       else
        #         action = "Booking cancelled of "+unit_details[:unit_type]+" by "+user[:name]
        #       end
        #       log = Log.new(:unit_number=>unit_details[:unit_number], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :remark=>"Booking Confirmation Updated", :admin_user_id=>params[:admin_user_id])
        #       log.save
        #       ## send notification
        #       reg_id = User.where("id!=?",user[:id]).select('token')
        #       registration_id = []
        #       reg_id.each{ |x| registration_id.push x[:token]}
        #       fcm_push_notification(action, registration_id, 'Booking Confirmation Updated')
        #     end
        #     if params[:SPA_signed] != nil
        #       p "ghusa spa"
        #       action = nil
        #       if params[:SPA_signed] == true
        #         action = "SPA signed of "+unit_details[:unit_type]+" by "+user[:name]
        #       else
        #         action = "SPA Unsigned of "+unit_details[:unit_type]+" by "+user[:name]
        #       end
        #       log = Log.new(:unit_number=>unit_details[:unit_number], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :remark=>"SPA Signed Updated", :admin_user_id=>params[:admin_user_id])
        #       log.save
        #       ## send notification
        #       reg_id = User.where("id!=?",user[:id]).select('token')
        #       registration_id = []
        #       reg_id.each{ |x| registration_id.push x[:token]}
        #       fcm_push_notification(action, registration_id, 'SPA Details Updated')
        #     end
        #     if params[:disbursement] != nil
        #       p "ghusa dis"
        #       action = nil
        #       if params[:disbursement] == true
        #         action = "disbursment done of "+unit_details[:unit_type]+" by "+user[:name]
        #       else
        #         action = "disbursment not done of "+unit_details[:unit_type]+" by "+user[:name]
        #       end
        #       log = Log.new(:unit_number=>unit_details[:unit_number], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :remark=>"Disbursment details Updated", :admin_user_id=>params[:admin_user_id])
        #       log.save
        #       ## send notification
        #       reg_id = User.where("id!=?",user[:id]).select('token')
        #       registration_id = []
        #       reg_id.each{ |x| registration_id.push x[:token]}
        #       fcm_push_notification(action, registration_id, 'Disbursement details Updated')
        #     end
        #     if params[:handover] != nil
        #       p "ghusa hand"
        #       action = nil
        #       if params[:handover] == true
        #         action = "handover done of "+unit_details[:unit_type]+" by "+user[:name]
        #       else
        #         action = "handover not done of "+unit_details[:unit_type]+" by "+user[:name]
        #       end
        #       log = Log.new(:unit_number=>unit_details[:unit_number], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :remark=>"Handover details Updated", :admin_user_id=>params[:admin_user_id])
        #       log.save
        #       ## send notification
        #       reg_id = User.where("id!=?",user[:id]).select('token')
        #       registration_id = []
        #       reg_id.each{ |x| registration_id.push x[:token]}
        #       fcm_push_notification(action, registration_id, 'Handover details Updated')
        #     end
        #     render json: {status: '1', msg: 'Booking details Updated', data: booking_detail}, status: :ok
        #   else
        #     render json: {status: '0', msg: 'Booking detail not Updated', data: booking_detail.error}, status: :ok
        #   end
        # end
      end

      def image
        if params[:name] && params[:id]
          path = "public/assets/"+params[:id]+"/"+params[:name]
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
        bookings = BookingDetail.where("booked_by_user_id=?",params[:id]).joins("INNER JOIN unit_details b on booking_details.unit_id=b.id").select('*, booking_details.id as booking_id')
        render json: {status: '1', msg: 'Booking details of Agent', data: bookings}, status: :ok
      end

      def getAllFiles
        a = Dir["public/assets/"+params[:id].to_s+"/*"]
        if a.length < 1
          a = Dir["public/assets/*"]
        end

        if a.length < 1
          a = Dir["public/*"]
        end
        
        render json: {status: '1', msg: 'Booking receipts of Agent', data:a}, status: :ok
      end

      private

      def new_booking(params)
        path = 'public/assets/'
        file = params[:payment_receipt]
        params[:payment_receipt]= name = file.original_filename
        Dir.mkdir(path) unless Dir.exist?(path)
        Dir.mkdir(path+'/'+params[:booked_by_user_id].to_s) unless Dir.exist?(path+'/'+params[:booked_by_user_id].to_s)
        path += params[:booked_by_user_id].to_s+'/'+name
        unit_details = UnitDetail.find(params[:unit_id])

        if unit_details.is_booked && unit_details.unit_availability=='Available'
          return "this unit is already booked", "0"
        end

        if File.exist?(path)
          return "booking receipt not saved because receipt already exists", "0"
        end

        File.open(path, "wb") do |f|
          name = f.write(File.read(file))
        end

        unless File.exist?(path)
          return "booking receipt not saved", "0"
        end

        booking_detail = BookingDetail.new(booking_details_params)
        unit_details.update(:is_booked=>true, :unit_availability=> "Booked")

        unless booking_detail.save
          return "Booking details not saved", "0"
        end

        user = User.find(booking_detail[:booked_by_user_id])
        action = "New booking of unit: "+unit_details[:unit_block]+"-"+unit_details[:unit_floor]+"-"+unit_details[:unit_number]+" done by "+user[:name]
        log = Log.new(:unit_number=>booking_detail[:id], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :remark=>"New Booking", :admin_user_id=>params[:booked_by_user_id])
        log.save
        ## send notification
        reg_id = User.where("id!=?",user[:id]).select('token')
        registration_id = []
        reg_id.each{ |x| registration_id.push x[:token]}
        fcm_push_notification(action, registration_id, 'New Booking')
        return "saved booking details", "1", booking_detail
      end

      def update_receipt(params)
        p "update receipt"
        booking_detail = BookingDetail.find(params[:id])
        path = "public/assets/"
        file = params[:payment_receipt]
        name = file.original_filename
        params[:payment_receipt]= file.original_filename
        # path = path+booking_detail.booked_by_user_id.to_s+"/"+booking_detail.payment_receipt
        # p "path"
        # p path
        # File.delete(path) if File.exist?(path)
        path = "public/assets/"
        Dir.mkdir(path) unless Dir.exist?(path)
        path = path+booking_detail.booked_by_user_id.to_s
        Dir.mkdir(path) unless Dir.exist?(path)
        path = path+"/"+name

        if File.exist?(path)
          return "Receipt already exists", "0"
        end

        File.open(path, "wb") do |f|
          f.write(File.read(file)) if file
        end

        if File.exist?(path)
          return "Receipt updated successfully", "1"
        end
      end

      def update_booking(params)
        p "receipt"
        p params[:payment_receipt]
        booking_detail = BookingDetail.find(params[:id])
        unless booking_detail.update(booking_details_params)
          return "Update failed", "0"
        end

        unit_details = UnitDetail.find(booking_detail[:unit_id])
        user = User.find(params[:admin_user_id])
        reg_id = User.where("id!=?",user[:id]).select('token')
        registration_id = []
        reg_id.each{ |x| registration_id.push x[:token]}

        if params[:booking_confirmation] != nil
          action = nil
          if params[:booking_confirmation] == true
            action = "Booking confirmed of "+unit_details[:unit_block]+"-"+unit_details[:unit_floor]+"-"+unit_details[:unit_number]+" by "+user[:name]
          else
            action = "Booking cancelled of "+unit_details[:unit_block]+"-"+unit_details[:unit_floor]+"-"+unit_details[:unit_number]+" by "+user[:name]
          end
          log = Log.new(:unit_number=>booking_detail[:id], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :remark=>"Booking Confirmation Updated", :admin_user_id=>params[:admin_user_id])
          log.save
          ## send notification
          fcm_push_notification(action, registration_id, 'Booking Confirmation Updated')
        end

        if params[:SPA_signed] != nil
          action = nil
          if params[:SPA_signed] == true
            action = "SPA signed of "+unit_details[:unit_block]+"-"+unit_details[:unit_floor]+"-"+unit_details[:unit_number]+" by "+user[:name]
          else
            action = "SPA Unsigned of "+unit_details[:unit_block]+"-"+unit_details[:unit_floor]+"-"+unit_details[:unit_number]+" by "+user[:name]
          end
          log = Log.new(:unit_number=>booking_detail[:id], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :remark=>"SPA Signed Updated", :admin_user_id=>params[:admin_user_id])
          log.save
          ## send notification
          fcm_push_notification(action, registration_id, 'SPA Signed Updated')
        end

        if params[:disbursement] != nil
          action = nil
          if params[:disbursement] == true
            action = "disbursment done of "+unit_details[:unit_block]+"-"+unit_details[:unit_floor]+"-"+unit_details[:unit_number]+" by "+user[:name]
          else
            action = "disbursment not done of "+unit_details[:unit_block]+"-"+unit_details[:unit_floor]+"-"+unit_details[:unit_number]+" by "+user[:name]
          end
          log = Log.new(:unit_number=>booking_detail[:id], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :remark=>"Disbursment details Updated", :admin_user_id=>params[:admin_user_id])
          log.save
          ## send notification
          fcm_push_notification(action, registration_id, 'Disbursement details Updated')
        end

        if params[:handover] != nil
          action = nil
          if params[:handover] == true
            action = "handover done of "+unit_details[:unit_block]+"-"+unit_details[:unit_floor]+"-"+unit_details[:unit_number]+" by "+user[:name]
          else
            action = "handover not done of "+unit_details[:unit_block]+"-"+unit_details[:unit_floor]+"-"+unit_details[:unit_number]+" by "+user[:name]
          end
          log = Log.new(:unit_number=>booking_detail[:id], :user_id=>booking_detail[:booked_by_user_id], :action=>action, :remark=>"Handover details Updated", :admin_user_id=>params[:admin_user_id])
          log.save
          ## send notification
          fcm_push_notification(action, registration_id, 'Handover Details Updated')
        end

        return "Booking details Updated", "1", booking_detail

      end



      def fcm_push_notification(message, registration_ids, title)
        fcm_client = FCM.new('AAAAWaIbzRY:APA91bEiB_2uHtHGkBN-NVrZnkhDvbvdmkcPYKywv8-dqOUMc1Z25zI9tHtEIYykGMC3PElYjdYEFTcVE7A_QbFIoMiwZIfDGLAyPG4JxTXbrMtFiHhBcntHKNpy2QrZrBJdCb8cTRJf') # set your FCM_SERVER_KEY
        options = { 
                    priority: 'high',
                    data: { click_action: 'FLUTTER_NOTIFICATION_CLICK'},
                    notification: { body: message,
                                    title: title,
                                    sound: 'default'
                                  }
                  }
        #([Array of registration ids up to 1000])
        # Registration ID looks something like: "dAlDYuaPXes:APA91bFEipxfcckxglzRo8N1SmQHqC6g8SWFATWBN9orkwgvTM57kmlFOUYZAmZKb4XGGOOL9wqeYsZHvG7GEgAopVfVupk_gQ2X5Q4Dmf0Cn77nAT6AEJ5jiAQJgJ_LTpC1s64wYBvC"
        registration_ids.each_slice(20) do |registration_id|
          response = fcm_client.send(registration_id, options)
          puts response
        end
      end


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