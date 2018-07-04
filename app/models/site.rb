class Site < ApplicationRecord

  enum status: %i[submitted started succeeded failed]

  belongs_to :user, counter_cache: true

  has_one_attached :image

  after_create :process!
  def process!
    started!
    ImageGenerationWorker.perform_async(self.id)
  end

  URL_VALID_FORMAT = '\A((http|https):\/\/)*[a-z0-9_-]{1,}\.*[a-z0-9_-]{1,}\.[a-z]{2,5}(\/)?\S*\z'
  validates :user, presence: true
  validates :url, format: /#{URL_VALID_FORMAT}/i
  validates :callback_url, format: /\A\z|#{URL_VALID_FORMAT}/i

end
