class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2]

  belongs_to :unit
  belongs_to :team
  has_many :bills, dependent: :destroy
  has_many :invitations, foreign_key: "receiver_id", dependent: :destroy
  has_many :senders, through: :invitations

  validates :phone, length: { is: 10 }, if: "!phone.nil?"
  validates :phone, numericality: { only_integer: true }

  def area_code
    self.phone.slice(0,3)
  end

  def exchange
    self.phone.slice(3,3)
  end

  def line
    self.phone.slice(6,4)
  end

  def phone_string
    "#{self.area_code}-#{self.exchange}-#{self.line}"
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
    end
  end

  def first_name_or_email
    return email_without_domain if first_name.nil? || first_name.empty?
    first_name
  end

  # Replace with actual score computation
  def score
    today = Time.now
    last = today.beginning_of_month - 1.day
    simple_today = Time.new(today.year, today.month)
    simple_last = Time.new(last.year, last.month)
    bill_today = self.bills.select { |bill| bill.bill_received.year == simple_today.year && bill.bill_received.month == simple_today.month }
    bill_last = self.bills.select { |bill| bill.bill_received.year == simple_last.year && bill.bill_received.month == simple_last.month }
    if bill_today.length == 1 && bill_last.length == 1
      return bill_last.first.amount - bill_today.first.amount
    else
      return 0
    end
  end

  private

  def email_without_domain
    email.split('@').first
  end
end
