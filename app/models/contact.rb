class Contact < ApplicationRecord
  has_and_belongs_to_many :tags

  validates :first_name, presence: true

  scope :search, ->(q) {
    return all if q.blank?
    where("first_name LIKE :q OR last_name LIKE :q OR email LIKE :q OR
           phone_mobile LIKE :q OR phone_home LIKE :q OR phone_work LIKE :q OR
           city LIKE :q", q: "%#{q}%")
  }

  scope :with_tag, ->(tag_id) {
    return all if tag_id.blank?
    joins(:tags).where(tags: { id: tag_id })
  }

  def full_name
    [first_name, last_name].compact.join(" ")
  end

  def full_address
    parts = [street, city, state, zip, country].reject(&:blank?)
    parts.join(", ")
  end

  def to_vcard
    lines = ["BEGIN:VCARD", "VERSION:3.0"]
    lines << "N:#{vcard_escape(last_name)};#{vcard_escape(first_name)};;;"
    lines << "FN:#{vcard_escape(full_name)}"
    lines << "EMAIL;TYPE=INTERNET:#{vcard_escape(email)}"           if email.present?
    lines << "TEL;TYPE=HOME:#{vcard_escape(phone_home)}"            if phone_home.present?
    lines << "TEL;TYPE=WORK:#{vcard_escape(phone_work)}"            if phone_work.present?
    lines << "TEL;TYPE=CELL:#{vcard_escape(phone_mobile)}"          if phone_mobile.present?
    if [street, city, state, zip, country].any?(&:present?)
      lines << "ADR;TYPE=HOME:;;#{vcard_escape(street)};#{vcard_escape(city)};#{vcard_escape(state)};#{vcard_escape(zip)};#{vcard_escape(country)}"
    end
    lines << "BDAY:#{birthday.strftime('%Y-%m-%d')}"                if birthday.present?
    lines << "NOTE:#{vcard_escape(notes)}"                          if notes.present?
    lines << "CATEGORIES:#{tags.map(&:name).map { |t| vcard_escape(t) }.join(',')}" if tags.any?
    lines << "END:VCARD"
    lines.join("\r\n")
  end

  def self.from_vcard(vcard_text)
    contacts = []
    vcard_text.scan(/BEGIN:VCARD.*?END:VCARD/m).each do |card|
      c = Contact.new
      fields = card.lines.map(&:strip)
      fields.each do |line|
        key, value = line.split(":", 2)
        next if value.nil?
        value = value.strip
        case key.upcase.split(";").first
        when "N"
          parts = value.split(";")
          c.last_name  = parts[0].presence
          c.first_name = parts[1].presence || "Unknown"
        when "FN"
          c.first_name ||= value.split(" ").first
          c.last_name  ||= value.split(" ")[1..]&.join(" ")
        when "EMAIL"
          c.email = value
        when "TEL"
          type = key.upcase
          if type.include?("HOME")
            c.phone_home = value
          elsif type.include?("WORK")
            c.phone_work = value
          elsif type.include?("CELL") || type.include?("MOBILE")
            c.phone_mobile = value
          else
            c.phone_mobile ||= value
          end
        when "ADR"
          parts = value.split(";")
          c.street  = parts[2].presence
          c.city    = parts[3].presence
          c.state   = parts[4].presence
          c.zip     = parts[5].presence
          c.country = parts[6].presence
        when "BDAY"
          c.birthday = Date.parse(value) rescue nil
        when "NOTE"
          c.notes = value
        end
      end
      contacts << c if c.first_name.present?
    end
    contacts
  end

  private

  def vcard_escape(str)
    return "" if str.blank?
    str.to_s.gsub("\\", "\\\\").gsub(",", "\\,").gsub(";", "\\;").gsub("\n", "\\n")
  end
end
