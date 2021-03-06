class WelcomeController < ApplicationController
  def test
  	response = HTTParty.get("http://api.wunderground.com/api/#{ENV['wunderground_api_key']}/geolookup/conditions/q/MI/Detroit.json")
  



  @location = response['location']['city']
  @temp_f = response['current_observation']['temp_f']
  @temp_c = response['current_observation']['temp_c']
  @weather_icon = response['current_observation']['icon_url']
  @weather_words = response['current_observation']['weather'] 
  @forecast_link = response['current_observation']['forecast_url']
  @real_feel = response['current_observation']['feelslike_f']


  end

  def index
  	# Creates an array of states that our user can choose from on our index page
  	@my_locations = Location.all

  	@body_class = "default"
    @states = %w(HI AK CA OR WA ID UT NV AZ NM CO WY MT ND SD NB KS OK 
		 TX LA AR MO IA MN WI IL IN MI OH KY TN MS AL GA FL SC NC VA WV DE MD PA NY 
		 NJ CT RI MA VT NH ME DC).sort!

		 if params[:city] != nil
		 		params[:city].gsub!(' ','_')

		 end 	

		 #checks that the state and city params are not empty before calling the API
      if params[:state] != "" && params[:city] != "" && params[:state] != nil && params[:city] != nil
		 
	 		results = HTTParty.get("http://api.wunderground.com/api/#{Figaro.env.wunderground_api_key}/geolookup/conditions/q/#{params[:state]}/#{params[:city]}.json")


		puts "-----------BEGIN OF RESPONSE--------------"
		puts results
		puts "-----------END OF RESPONSE--------------"
		  

    # if no error is returned from the call, we fill our instants variables with the result of the call
		 
      if results['response']['error'] == nil || results['error'] ==""  	
		    @location = results['location']['city']
		    @temp_f = results['current_observation']['temp_f']
		    @temp_c = results['current_observation']['temp_c']
	            @weather_icon = results['current_observation']['icon_url']
		    @weather_words = results['current_observation']['weather']
	            @forecast_link = results['current_observation']['forecast_url']
		    @real_feel_f = results['current_observation']['feelslike_f']
		    @real_feel_c = results['current_observation']['feelslike_c']
	 		
				if @weather_words == "Sunny" || @weather_words == "Clear"
								@body_class = "sunny"
							elsif @weather_words == "Snow"
								@body_class = "snow"
							elsif @weather_words.include?('Rain') || @weather_words == "Shower"	
								@body_class = "rain"

							elsif @weather_words == "Overcast" || @weather_words == "Mostly Cloudy"
								@body_class = "cloudy"
							elsif @weather_words.include?('Fog') 	
								@body_class = "foggy"	
							elsif @weather_words == "Partly Cloudy" || @weather_words == "Partly Sunny"
								@body_class = "partly_sunny"	
						
								
				end		 	
		    @check = @my_locations.where(city: params[:city], state: params[:state])
		    	if @check.empty?

		    		@new_location = Location.create(city: params[:city], state: params[:state])
		    		@new_location.save
		    	end		



		    
	 		else

    # if there is an error, we report it to our user via the @error variable 	
	    	@error = results['response']['error']['description']
	    	
    	 end
		   
    end


		
	



  end
end
