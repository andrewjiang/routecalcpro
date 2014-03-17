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
    file_path = File.absolute_path(params[:file])

    CSV.foreach(file_path, headers: true) do |row|
      if $. <= 11
        Route.create! row.to_hash
      end
    end

    Route.find_each do |route|
      if route.driving_distance == nil
        @origin = route.origin.gsub(/\s+/, '%20').gsub(/[^0-9A-Za-z%]/, '')
        puts @origin
        @destination = route.destination.gsub(/\s+/, '%20').gsub(/[^0-9A-Za-z%]/, '')
        puts @destination

        url = URI.parse('http://maps.googleapis.com/maps/api/directions/json?origin=' + @origin + '&destination=' + @destination + '&sensor=false')
        req = Net::HTTP::Get.new(url.to_s)
        res = Net::HTTP.start(url.host, url.port) {|http|
          http.request(req)
        }
        result1 = res.body
        parsed_json = ActiveSupport::JSON.decode(result1)
        @distance = (parsed_json["routes"][0]["legs"][0]["distance"]["value"] / 1609.34).round(1)
        @duration = (parsed_json["routes"][0]["legs"][0]["duration"]["value"] / 60).round(0)
        route.update_attribute(:driving_distance, @distance)
        route.update_attribute(:driving_time, @duration)
      else
        puts "Not empty"
      end
    end

    redirect_to root_url, notice: "Routes imported"
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
