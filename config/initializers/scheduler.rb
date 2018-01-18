require 'rufus-scheduler'
require 'rest-client'
require 'json'

  scheduler = Rufus::Scheduler::singleton
  
  ##--
  ## Created By: ChTete
  ## Created On: 03/08/2017
  ## Purpose: To fetch google reviews for each clients with respect to their locations.
  #++
  scheduler.every '20m'  do
    #1 retrive all clients from db
    notifications_users = []
    clients = Client.all.where.not(name: "superadmin")
    #2 get refresh tokens of all clients
    refresh_tokens =  clients.collect {|p| p.google_refresh_token}
    google_client_ids =  clients.collect {|p| p.google_client_id}
    google_secret_keys =  clients.collect {|p| p.google_secret_key}
    google_account_names =  clients.collect {|p| p.google_account_name}
    client_ids = clients.collect {|p| p.id}
    #3 loop for each client
    client_ids.each_with_index do |client_id, index|
      refresh_token =  refresh_tokens[index]
      #4 if refresh_token is not nil 
      if refresh_token != nil and refresh_token != ""
        #5 get all locations of perticular client
        locations = Location.where(clients_id: client_id)
        location_ids =  locations.collect {|p| p.id}
        google_location_ids = locations.collect {|p| p.google_location_id}      
        #6 loop for each locations of perticular client
        count = 0
        location_ids.each do |location_id|
          google_location_id =  google_location_ids[count]
          #7 if google_location id is present then do further else end  
          if google_location_id != nil and google_location_id != ""
            #8 API call to generate access token of perticular client using its refresh token
            begin
              @auth_params = RestClient.post "https://www.googleapis.com/oauth2/v4/token", { client_id: google_client_ids[index],  client_secret: google_secret_keys[index], refresh_token: refresh_token, grant_type: "refresh_token" }
              access_token = JSON.parse(@auth_params).first
              gen_access_token = access_token.last
            rescue => e
              e.response
            end
            #9 if access token generated successfully generated then insert go to fetch reviews
            begin
              @google_reviews = RestClient.get "https://mybusiness.googleapis.com/v3/accounts/#{google_account_names[index]}/locations/#{google_location_id}/reviews?access_token=#{gen_access_token}"
              @reviews = JSON.parse(@google_reviews)
              star_rating = ['ONE', 'TWO', 'THREE', 'FOUR', 'FIVE']
              @reviews["reviews"].each do |r|
                create_time = r["createTime"]
                create_time = create_time.sub("T"," ")
                update_time = r["updateTime"]
                update_time = update_time.sub("T"," ") 
                star = star_rating.index(r['starRating'])+1
                if !GoogleReview.where(:google_review_id => r["reviewId"]).exists?
                  @insert_google_reviews = GoogleReview.new(google_review_id: r["reviewId"], star_rating: star, reviewer_name: r["reviewer"]["displayName"],review_comment: r["comment"], location_id: location_id, google_review_create_time: create_time, google_review_update_time: update_time, client_id: client_id)
                  @insert_google_reviews.save
                  notifications_users.push(client_id)
                end
              end 
            rescue => e
              e.response
            end
            # reviews fetch end
          end
          count = count+1
        end
      end
    end
    new_review =  NotificationType.find_by(notification_name: "New Review")
    notifications_users.each do |client_id|
  
    users = User.where(:client_id => client_id)
      users.each do |user|
        # sending email notifications
        if NotificationSetting.find_by(users_id: user.id, notification_types_id: new_review.id).email_notification_type   
          data = JSON.parse({
          "personalizations": [
            {
              "to": [
                {
                  "email": user.email
                }
              ],
                "subject": "#{new_review.notification_name} Notification"
              }
            ],
          "from": {
            "email": "mark@reviewmaiden.com"
          },
          "content": [
            {
              "type": "text/html",
              "value": "New Review is Added in ReviewMaiden."
            }                                                  
          ]
          }.to_json)                                                     
          send_grid = SendGrid::API.new(api_key:"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")
          response = send_grid.client.mail._("send").post(request_body: data) 
        end
        #sending sms notifications
        if NotificationSetting.find_by(users_id: user.id, notification_types_id: new_review.id).push_notification_type        
          begin 
            client = Twilio::REST::Client.new ENV["TWILIO_ACC_SID"], ENV["TWILIO_AUTH_TOKEN"]
            response = client.messages.create(
              from: ENV["TWILIO_NO"],
              to:   user.primary_mobile_no,
              body: "New Review is Added in ReviewMaiden"
            )
          rescue Twilio::REST::RequestError => twilio_error
            # return e.message
          end
        end
      end
    end
  end