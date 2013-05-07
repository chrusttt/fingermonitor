class MeasurementsController < ApplicationController
 before_filter :authenticate_user!
def create
    @measurement = Measurement.new(params[:measurement])

    respond_to do |format|
      if @measurement.save
       render status: 200, json: {message: "Success"}
      else
        render status: 401, json: {message: "Failure"}
      end
    end
  end

end