class CompanySerializer #serializes companies into JSON documents
  def initialize(company)
    @company = company
  end

  def as_json(*)
    data = {
      id:@company.id.to_s,
      cvr:@company.cvr,
    	name:@company.name,
    	address:@company.address,
    	city:@company.city,
    	country:@company.country,
    	phone:@company.phone
    }
    data[:errors] = @company.errors if@company.errors.any?
    data
  end
end
