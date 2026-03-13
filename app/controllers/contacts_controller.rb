require "csv"

class ContactsController < ApplicationController
  before_action :set_contact, only: [:show, :edit, :update, :destroy]

  def index
    @tags = Tag.order(:name)
    @contacts = Contact.search(params[:q])
                       .with_tag(params[:tag_id])
                       .includes(:tags)
                       .order(:last_name, :first_name)
    @active_tag = Tag.find_by(id: params[:tag_id]) if params[:tag_id].present?
  end

  def show
  end

  def new
    @contact = Contact.new
    @tags = Tag.order(:name)
  end

  def create
    @contact = Contact.new(contact_params)
    if @contact.save
      redirect_to @contact, notice: "Contact created successfully."
    else
      @tags = Tag.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @tags = Tag.order(:name)
  end

  def update
    if @contact.update(contact_params)
      redirect_to @contact, notice: "Contact updated successfully."
    else
      @tags = Tag.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contact.destroy
    redirect_to contacts_path, notice: "Contact deleted."
  end

  def export
    contacts = Contact.search(params[:q])
                      .with_tag(params[:tag_id])
                      .includes(:tags)
                      .order(:last_name, :first_name)

    vcard_data = contacts.map(&:to_vcard).join("\r\n")

    respond_to do |format|
      format.vcf do
        send_data vcard_data,
                  filename: "contacts_#{Date.today}.vcf",
                  type: "text/vcard",
                  disposition: "attachment"
      end
      format.csv do
        csv_data = generate_csv(contacts)
        send_data csv_data,
                  filename: "contacts_#{Date.today}.csv",
                  type: "text/csv",
                  disposition: "attachment"
      end
      format.html { redirect_to contacts_path }
    end
  end

  def import
    file = params[:file]
    if file.nil?
      redirect_to contacts_path, alert: "Please select a file to import."
      return
    end

    content = file.read.force_encoding("UTF-8")
    ext = File.extname(file.original_filename).downcase

    imported = 0
    errors   = 0

    if ext == ".vcf"
      contacts = Contact.from_vcard(content)
      contacts.each do |c|
        imported += 1 if c.save
        errors   += 1 unless c.save || c.persisted?
      end
    elsif ext == ".csv"
      CSV.parse(content, headers: true) do |row|
        c = Contact.new(
          first_name:   row["first_name"] || row["First Name"],
          last_name:    row["last_name"]  || row["Last Name"],
          email:        row["email"]      || row["Email"],
          phone_home:   row["phone_home"] || row["Home Phone"],
          phone_work:   row["phone_work"] || row["Work Phone"],
          phone_mobile: row["phone_mobile"] || row["Mobile"],
          street:       row["street"]     || row["Street"],
          city:         row["city"]       || row["City"],
          state:        row["state"]      || row["State"],
          zip:          row["zip"]        || row["Zip"],
          country:      row["country"]    || row["Country"],
          notes:        row["notes"]      || row["Notes"]
        )
        imported += 1 if c.save
        errors   += 1 unless c.persisted?
      end
    else
      redirect_to contacts_path, alert: "Unsupported file type. Please upload a .vcf or .csv file."
      return
    end

    redirect_to contacts_path, notice: "Imported #{imported} contacts. #{errors > 0 ? "#{errors} failed." : ""}"
  end

  private

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(
      :first_name, :last_name, :email,
      :phone_home, :phone_work, :phone_mobile,
      :street, :city, :state, :zip, :country,
      :birthday, :notes,
      tag_ids: []
    )
  end

  def generate_csv(contacts)
    headers = %w[first_name last_name email phone_home phone_work phone_mobile
                 street city state zip country birthday notes tags]
    CSV.generate(headers: headers, write_headers: true) do |csv|
      contacts.each do |c|
        csv << [
          c.first_name, c.last_name, c.email,
          c.phone_home, c.phone_work, c.phone_mobile,
          c.street, c.city, c.state, c.zip, c.country,
          c.birthday, c.notes,
          c.tags.map(&:name).join("|")
        ]
      end
    end
  end
end
