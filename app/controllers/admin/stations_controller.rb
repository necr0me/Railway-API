module Admin
  class StationsController < AdminController
    before_action :find_station, only: %i[update destroy]
    before_action :authorize_station

    def index
      @stations = Station.where("name LIKE :prefix", prefix: "#{params[:station]}%")
      @pagy, @stations = pagy(@stations, page: params[:page] || 1)
      render json: { stations: StationSerializer.new(@stations),
                     pages: @pagy.pages }
    end

    def create
      station = Station.create(station_params)
      if station.persisted?
        render json: { station: StationSerializer.new(station) },
               status: :created
      else
        render json: { message: "Something went wrong",
                       errors: station.errors },
               status: :unprocessable_entity
      end
    end

    def update
      if @station.update(station_params)
        render json: { station: StationSerializer.new(@station) },
               status: :ok
      else
        render json: { message: "Something went wrong",
                       errors: @station.errors },
               status: :unprocessable_entity
      end
    end

    def destroy
      if @station.destroy
        head :no_content
      else
        render json: { message: "Something went wrong",
                       errors: @station.errors },
               status: :unprocessable_entity
      end
    end

    private

    def station_params
      params.require(:station).permit(:name)
    end

    def find_station
      @station = Station.find(params[:id].to_i)
    end

    def authorize_station
      authorize(@station || Station)
    end
  end
end
