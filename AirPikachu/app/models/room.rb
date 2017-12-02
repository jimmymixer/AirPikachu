class Room < ApplicationRecord
  belongs_to :user
  has_many :photos
  has_many :reservations
  has_many :guest_reviews

  geocoded_by :address
  after_validation :geocode, if: :address_changed?

  validates :home_type, presence: true
  validates :room_type, presence: true
  validates :accommodate, presence: true
  validates :bedroom, presence: true
  validates :bathroom, presence: true

  def cover_photo(size)
    # self is talking about the Room
    # same thing as saying room.photos, because we are under the rooms model
    # image.url() comes from papaerclip gem, we choose the :thumb size, paperclip will allow you have different sizes of thumb or medium
    # self.photos.length > 0  is.. Get the first photo of this room / Display only the first photo if there is at least 1 photo
    if self.photos.length > 0
      self.photos[0].image.url(size)
    else
      # else its going to display the default picture that we choosen
      "blank.jpg"
    end
  end

  def average_rating
    guest_reviews.count == 0 ? 0 : guest_reviews.average(:star).round(2).to_i
  end

end
