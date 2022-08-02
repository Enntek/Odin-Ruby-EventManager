require 'csv'
require 'erb'

csv = CSV.open(
  'attendees_short.csv',
  headers: true,
  header_converters: :symbol
)

template = File.read('sentence.html')
erb_template = ERB.new(template)

def save_greeting(id, greeting)
  # create dir
  Dir.mkdir('output2') unless Dir.exist?('output2')

  save_name = "output2/save_#{id}"
  # File.open(save_name, 'w')  { |file| file.puts(greeting) }
end

csv.each do |row|
  id = row[0]
  first_name = row[:first_name]
  last_name = row[:last_name]
  full_name = "#{first_name} #{last_name}"
  city = row[:city]

  # p full_name, city

  greeting = erb_template.result(binding)
  save_greeting(id, greeting)
end
