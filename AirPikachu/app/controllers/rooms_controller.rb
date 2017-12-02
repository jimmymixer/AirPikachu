class RoomsController < ApplicationController
  before_action :set_room, except: [:index, :new, :create]
  before_action :authenticate_user!, except: [:show]
  before_action :is_authorized, only: [:listing, :pricing, :description, :photo_upload, :amenities, :location, :update]

  def index
    @rooms = current_user.rooms
  end

  def new
    @room = current_user.rooms.build
  end

  def create
    @room = current_user.rooms.build(room_params)
    if @room.save
      redirect_to listing_room_path(@room), notice: "Saved..."
      # redirect_to listing_room_path(@room), flash.now[:notice] = "Saved..."
    else
      flash[:alert] = "Something went wrong..."
      render :new
      # render flash[:notice] = "Something went wrong...", :new
    end
  end

  def show
    # return all the photos we have for this @room
    @photos = @room.photos
    @guest_reviews = @room.guest_reviews
  end

  def listing
  end

  def pricin
  end

  def description
  end

  def photo_upload
    @photos = @room.photos
  end

  def amenities
  end

  def location
  end

  def update

    new_params = room_params
    new_params = room_params.merge(active: true) if is_ready_room


    if @room.update(new_params)
      flash[:notice] = "Saved..."
    else
      flash[:alert] = "Something went wrong..."
    end
    redirect_back(fallback_location: request.referer)
  end

  # ------- RESERVATIONS ---------
  def preload # Handle AJAX for reservations, block out unavailable dates
    today = Date.today
    reservations = @room.reservations.where("start_date >= ? OR end_date >= ?", today, today) # Get all the reservations of @room with a condition of ...

    render json: reservations # Passes back to client

    # Remember that when we create a new custom action "def preload" in the controller we need to tell Rails about that -> config/routes.rb
  end

  def preview
    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])

    output = {
      conflict: is_conflict(start_date, end_date, @room)
    }

    render json: output
  end

  private
    def is_conflict(start_date, end_date, room)
      check = room.reservations.where("? < start_date and end_date < ?", start_date, end_date)
      check.size > 0? true : false
    end

    def set_room
      @room = Room.find(params[:id])
    end

    def is_ready_room
      !@room.active && !@room.price.blank? && !@room.listing_name.blank? && !@room.photos.blank? && !@room.address.blank?
    end

    def is_authorized
      redirect_to root_path, alert: "You don't have permission!" unless current_user.id == @room.user_id
    end

    def room_params
       params.require(:room).permit(:home_type, :room_type, :accommodate, :bedroom, :bathroom, :listing_name, :summary, :address, :is_tv, :is_kitchen, :is_air, :is_heating, :is_internet, :price, :active)
    end
end
