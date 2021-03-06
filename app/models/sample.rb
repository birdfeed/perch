class Sample < ActiveRecord::Base
  has_many :scores
  has_and_belongs_to_many :experiments, join_table: 'experiments_samples', :uniq => true
  has_many :participants, through: :scores

  validates :name, presence: true

  default_scope { order('id DESC') }

  has_attached_file :audio, :storage => :s3, :s3_credentials => {
      :bucket => Rails.application.secrets.aws_s3_bucket,
      :access_key_id => Rails.application.secrets.aws_s3_id,
      :secret_access_key => Rails.application.secrets.aws_s3_secret
  }

  # TODO: Fix this horrible security hole
  # Paperclip's MIME type detection is fucked because it doesn't
  # call strip on the content-type itself, so \r\n are in there.
  # All you have to do is just sanitize the parameters after they've
  # been POSTed to the controllers, but because of due dates, FUCK this.

  # Accept any audio MIME type
  # validates_attachment_content_type :audio, content_type: "*/*"

  do_not_validate_attachment_file_type :audio

  acts_as_taggable

  def sample_display
    "ID: #{id} Name: #{name}"
  end
    
  # For data export
  def self.as_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |item|
        csv << item.attributes.values_at(*column_names)
      end
    end
  end

  private

  # Recalculate averages if scores are present
  def recalculate_average_and_total_scores
    if self.scores
      avg = 0
      self.scores.each do |score|
        avg += score.rating
      end

      self.update_attribute(:avg_score, avg / self.scores.length)
      self.update_attribute(:total_scores, self.scores.length)
    end
  end
end
