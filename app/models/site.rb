class Site < ApplicationRecord

  enum status: %i[submitted started succeeded failed]

  belongs_to :user, counter_cache: true

  has_one_attached :image

  after_create :process!
  def process!
    started!
    ImageGenerationWorker.perform_async(self.id)
  end

  validates :user, presence: true
  validates :url, format: /\A((http|https):\/\/)*[a-z0-9_-]{1,}\.*[a-z0-9_-]{1,}\.[a-z]{2,5}(\/)?\S*\z/i

end
