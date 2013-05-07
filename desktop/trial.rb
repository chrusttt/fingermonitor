class Trial

	attr_accessor :name, :date, :measurement_attributes

	def initialize(name, date, user)
		@name = name
		@date = date
		@user = user
	end

	def to_params
		{
			"trial" => {"name" => @name, "date"=> @date.httpdate, "user_id" => @user }
		}
	end


end
