class Company
	include Mongoid::Document #adds and manages Company objects in the DB

	#field :id, type: Integer
	field :cvr, type: String
	field :name, type: String
	field :address, type: String
	field :city, type: String
	field :country, type: String
	field :phone, type: Integer

	validates :cvr, presence: true
	validates :name, presence: true
	validates :address, presence: true
	validates :city, presence: true
	validates :country, presence: true

	index({ name: 'text' })
  index({ cvr:1 }, { unique: true, name: "cvr_index" }) #dont know about this

#used for db search. Name is different because this syntax allows for partial matches. case sensitive
	scope :name, -> (name) { where(name: /^#{name}/) }
  scope :cvr, -> (cvr) { where(cvr: cvr) }
  scope :address, -> (address) { where(address: address) }
end
