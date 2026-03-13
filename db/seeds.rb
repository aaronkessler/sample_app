# Create default tags
tags = ["Holiday Card", "Birthday Gift", "Family", "Friends", "Work", "Neighbors"].map do |name|
  Tag.find_or_create_by!(name: name)
end

puts "Created #{tags.count} tags"

# Create sample contacts
sample_contacts = [
  {
    first_name: "Mary",  last_name: "Johnson",
    email: "mary.johnson@example.com", phone_mobile: "(555) 234-5678",
    street: "45 Oak Avenue", city: "Boston", state: "MA", zip: "02101", country: "USA",
    notes: "Met at the book club. Loves gardening.",
    tag_names: ["Holiday Card", "Friends"]
  },
  {
    first_name: "Robert", last_name: "Williams",
    email: "rob.williams@example.com", phone_home: "(555) 345-6789", phone_work: "(555) 345-6780",
    street: "88 Elm Street", city: "Boston", state: "MA", zip: "02102", country: "USA",
    birthday: Date.new(1975, 6, 15),
    tag_names: ["Holiday Card", "Family"]
  },
  {
    first_name: "Patricia", last_name: "Brown",
    email: "pat.brown@example.com", phone_mobile: "(555) 456-7890",
    street: "12 Pine Road", city: "Cambridge", state: "MA", zip: "02139", country: "USA",
    notes: "Neighbors across the street. Dog named Max.",
    tag_names: ["Neighbors", "Holiday Card"]
  },
  {
    first_name: "James", last_name: "Davis",
    email: "james.davis@example.com", phone_mobile: "(555) 567-8901",
    city: "Somerville", state: "MA", country: "USA",
    birthday: Date.new(1988, 3, 22),
    tag_names: ["Friends"]
  },
  {
    first_name: "Linda", last_name: "Miller",
    email: "linda.miller@example.com", phone_home: "(555) 678-9012",
    street: "300 Maple Drive", city: "Newton", state: "MA", zip: "02458", country: "USA",
    tag_names: ["Holiday Card", "Family"]
  }
]

sample_contacts.each do |attrs|
  tag_names = attrs.delete(:tag_names) || []
  contact = Contact.find_or_create_by!(first_name: attrs[:first_name], last_name: attrs[:last_name]) do |c|
    c.assign_attributes(attrs)
  end
  contact.tags = tag_names.map { |name| Tag.find_by!(name: name) }
  contact.save!
end

puts "Created #{Contact.count} sample contacts"
puts "Seeds complete! Use /signup to create your account."
