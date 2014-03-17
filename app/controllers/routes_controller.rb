class RoutesController < ApplicationController
  before_action :set_route, only: [:show, :edit, :update, :destroy]

  # GET /routes
  # GET /routes.json
  def index
    @routes = Route.all
    respond_to do |format|
      format.html
      format.csv { send_data @routes.to_csv }
      format.xls #{ send_data @routes.to_csv(col_sep: "\t")}
    end
  end

  # GET /routes/1
  # GET /routes/1.json
  def show
  end

  def import
    #Route.import(params[:file])
    Route.destroy_all

    file_path = File.path(params[:file])

    CSV.foreach(file_path, headers: true) do |row|
      if $. <= 21
        Route.create! row.to_hash
      end
    end

    Route.find_each do |route|
      if route.driving_distance == nil
        @origin = route.origin.gsub(/\s+/, '%20').gsub(/[^0-9A-Za-z%]/, '')
        puts @origin
        @destination = route.destination.gsub(/\s+/, '%20').gsub(/[^0-9A-Za-z%]/, '')
        puts @destination
        @apikey = 'AIzaSyB-w7Z2JN-z6M24npOOyHAWgzlfJmq_VNw' #ENV["GMAPS_API_KEY"]

        uri = URI.parse('https://maps.googleapis.com/maps/api/directions/json?origin=' + @origin + '&destination=' + @destination + '&sensor=false&key=' + @apikey)
        puts 'https://maps.googleapis.com/maps/api/directions/json?origin=' + @origin + '&destination=' + @destination + '&sensor=false&key=' + @apikey
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Get.new(uri.request_uri)

        response = http.request(request)

        result1 = response.body
        parsed_json = ActiveSupport::JSON.decode(result1)
        puts parsed_json["status"]
        @distance = (parsed_json["routes"][0]["legs"][0]["distance"]["value"] / 1609.34).round(1)
        @duration = (parsed_json["routes"][0]["legs"][0]["duration"]["value"] / 60).round(0)
        route.update_attribute(:driving_distance, @distance)
        route.update_attribute(:driving_time, @duration)
      else
        puts "Not empty"
      end
    end

    redirect_to routes_path, notice: "Routes imported"
  end


  # GET /routes/new
  def new
    @route = Route.new
  end

  # GET /routes/1/edit
  def edit
  end

  # POST /routes
  # POST /routes.json
  def create
    @route = Route.new(route_params)

    respond_to do |format|
      if @route.save
        format.html { redirect_to @route, notice: 'Route was successfully created.' }
        format.json { render action: 'show', status: :created, location: @route }
      else
        format.html { render action: 'new' }
        format.json { render json: @route.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /routes/1
  # PATCH/PUT /routes/1.json
  def update
    respond_to do |format|
      if @route.update(route_params)
        format.html { redirect_to @route, notice: 'Route was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @route.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /routes/1
  # DELETE /routes/1.json
  def destroy
    @route.destroy
    respond_to do |format|
      format.html { redirect_to routes_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_route
      @route = Route.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def route_params
      params.require(:route).permit(:origin, :destination, :driving_distance, :driving_time)
    end
end
