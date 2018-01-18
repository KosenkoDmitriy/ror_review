class ResponsesController < ApplicationController
  before_action :authenticate_user!

  ##--
  ## Created By: MohSwaz
  ## Created On: 24/06/2017
  ## Purpose: To respond to the review in the recent review section first it will check for email if email exist the respond will be send to email otherwise to mobile number.
  #++
  def user_response
    @respond = params[:client_reply]
    req_id = Response.find_by(:id => Response.where(:id => params[:id]).ids).request_id
    review_req=Request.find_by(:id => req_id).review_user_id
    review_user1=ReviewUser.where(:id=>review_req)
    response=Response.find_by(:id => Response.where(:id => params[:id]).ids)
    @feedback = response.feedback
    @date = response.created_at.strftime("%d %B %Y")
    field_name=review_user1.pluck(:name).join(" ")
    field_email=review_user1.pluck(:email).join(" ")
    field_phone=review_user1.pluck(:phone_no).join(" ")
    if ((field_name != nil) && (field_name.match(/\A[^@\s]+@[^@\s]+\z/)!=nil))
      email_user = field_name
    elsif field_name.match(/^(\+\d{1,3}[-]?)?\d{10}$/ )!=nil
      phone_user = review_user1.pluck(:country_code).join("").concat(field_name)
    end 
    if ((field_email != nil) && (field_email.match(/\A[^@\s]+@[^@\s]+\z/)!=nil))
      email_user = field_email
    elsif field_email.match(/^(\+\d{1,3}[-]?)?\d{10}$/ )!=nil
      phone_user = review_user1.pluck(:country_code).join("").concat(field_email)
    end
    if ((field_phone != nil) && (field_email.match(/\A[^@\s]+@[^@\s]+\z/)!=nil))
      email_user = field_phone
    elsif field_phone.match(/^(\+\d{1,3}[-]?)?\d{10}$/ )!=nil
      phone_user = review_user1.pluck(:country_code).join("").concat(field_phone)
    end
    if email_user != nil
      @respond = params[:client_reply]
      email = email_user
      data = JSON.parse({
        "personalizations": [
          {
            "to": [
                {
                  "email": "#{email}"
                }
              ],
              "subject": "Response to your review"
            }
          ],
          "from": {
            "email": "mark@reviewmaiden.com"
          },
          "content": [
            {
              "type": "text/plain",
              "value": "Dear Reviewer,
                        Your Review Dated:#{@date} has been responded
              Text of your review: #{@feedback} 
              Respond is: #{@respond}"
            }
          ]
        }.to_json)
      sg = SendGrid::API.new(api_key: "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",host: 'https://api.sendgrid.com')
      response = sg.client.mail._("send").post(request_body: data)
      user_id = current_user.id
      ClientResponse.create(:client_reply => params[:client_reply], :response_id => params[:id], :user_id => user_id)
      flash[:notice] = 'Successfully Sent Respond'
    end
    if phone_user != nil
      begin
        phone_no=phone_user
        client = Twilio::REST::Client.new ENV["TWILIO_ACC_SID"], ENV["TWILIO_AUTH_TOKEN"]
        response = client.messages.create(
          from: ENV["TWILIO_NO"],
          to:   phone_no,
          body: "Dear Reviewer,
                        Your Review Dated:#{@date} has been responded
          Text of your review: #{@feedback} 
          Respond is: #{@respond}" 
        ) 
        user_id = current_user.id

        ClientResponse.create(:client_reply => params[:client_reply], :response_id => params[:id], :user_id => user_id)
        flash[:notice] = 'Successfully Sent Respond'
        rescue Twilio::REST::RequestError => e
      end
    end
    redirect_to home_index_path
  end

  ##--
  ## Created By: ChTete
  ## Created On: 18/08/2017
  ## Purpose: To add reply on postive review
  #++
  def google_review_reply
    google_review = GoogleReview.find(params[:id])
    client = Client.find(google_review.client_id)
    google_location_id = Location.find(google_review.location_id).google_location_id
    access_token = RestClient.post "https://www.googleapis.com/oauth2/v4/token", { client_id: "#{client.google_client_id}",  client_secret: "#{client.google_secret_key}", refresh_token: "#{client.google_refresh_token}", grant_type: "refresh_token" }
    gen_access_token = JSON.parse(access_token)["access_token"]
    uri = URI.parse("https://mybusiness.googleapis.com/v3/accounts/#{client.google_account_name}/locations/#{google_location_id}/reviews/#{google_review.google_review_id}/reply?access_token="+gen_access_token)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
    req = Net::HTTP::Post.new("https://mybusiness.googleapis.com/v3/accounts/#{client.google_account_name}/locations/#{google_location_id}/reviews/#{google_review.google_review_id}/reply?access_token="+gen_access_token)
    req.content_type = "application/json"
    req.body = {comment: params[:client_reply]}.to_json
    response = http.request(req)
    if  response.header.code.match("200").present?
      ClientResponse.create(:client_reply => params[:client_reply], :google_review_id => params[:id], :user_id => current_user.id)
      flash[:notice] = "Respond Successfully Added For The Location"
    else
      flash[:notice] = "Respond To The Location not Added" 
    end
    redirect_to home_index_path
  end
end

