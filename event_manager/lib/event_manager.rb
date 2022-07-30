require 'pry-byebug'

puts 'Event Manager Initialized'

template_letter = File.read('form_letter.html')

# puts File.exists?('event_attendees.csv')
# readlines saves each line as a separate item in an array
# lines = File.readlines('event_attendees.csv')

require 'csv'
contents = CSV.open('event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

def clean_zipcode(zip)
  zip.to_s.rjust(5, '0')[0..4] # nil.to_s = '' very handy to know
end

def legislators_by_zipcode(zipcode)
  require 'google/apis/civicinfo_v2'
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    info_object = civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    )
    legislators = info_object.officials
    legislator_names = legislators.map(&:name)
    legislator_names.join(', ') # join will connect items in an array with separator such as a comma
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end

  
end

contents.each do |row|
  # next if line == " ,RegDate,first_Name,last_Name,Email_Address,HomePhone,Street,City,State,Zipcode\n" # remember to use \n for new line here
  # next if index == 0

  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)
  
  # puts "#{name} #{zipcode} #{legislators}"
  personal_letter = template_letter.gsub('FIRST_NAME', name).gsub('LEGISLATORS', legislators)
  
  puts personal_letter
  break
end