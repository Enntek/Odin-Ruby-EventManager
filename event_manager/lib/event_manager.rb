# Odin Ruby Project: Event Manager
# https://www.theodinproject.com/lessons/ruby-event-manager

require 'pry-byebug'
require 'erb'
require 'csv'
require 'google/apis/civicinfo_v2'

def clean_zipcode(zip)
  zip.to_s.rjust(5, '0')[0..4] # nil.to_s = '' very handy to know
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

puts 'Event Manager Initialized'

# create folder 'output', save custom thank you letters
content = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

# use ERB to create letter template
letter = File.read('form_letter.erb')
template = ERB.new(letter)

# create method for saving each customized letter to your 'output' folder
# use 'id' to save
def save_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')
  # to save a file: use File.new
  # directory does not begin with /

  filename = "output/letter_#{id}.html"

  File.open(filename, 'w') do |file| # this looks like an arrow function
    file.puts form_letter
  end
end

def clean_ph_number(phone_number)
  num = phone_number.tr('^0-9', '')

  if num.length == 10
    num
  elsif num.length < 10 || num.length > 11
    '0000000000'
  elsif num.length == 11
    num[0] == '1' ? num : '0000000000'
  end
end

i = 0

reg_times = []
reg_dates = []

content.each do |row|
  id = row[0]
  signup_time = row[1]
  name = row[:first_name]
  phone_number = row[:homephone]
  zipcode = clean_zipcode(row[:zipcode])

  # phone_number = clean_ph_number(phone_number)
  # puts "#{name} #{phone_number}"

  # legislators = legislators_by_zipcode(zipcode)
  # form_letter = template.result(binding) # .result(binding) in scope of your variables
  # save_letter(id, form_letter)


  signup_time = DateTime.strptime(signup_time, '%m/%d/%y %k:%M') # first parse using strptime, then format using strftime  
  reg_times << signup_time.strftime("%H")
  reg_dates << signup_time.strftime("%A")
  # break if (i += 1) > 2
end

# get the hour at which people signed up
def tally_hours(array)
  array.map! { |item| item.to_i }
  
  array.sort! { |a, b| a <=> b }
  
  puts(array.reduce(Hash.new(0)) do |hash, num|
    hash[num] += 1
    hash
  end)
end

def tally_day(array)
  array.reduce(Hash.new(0)) do |hash, day|
    hash[day.to_sym] += 1
    hash
  end
end

tally_hours(reg_times)

p tally_day(reg_dates) # TOP: Use Date#wday to find out the day of the week.
