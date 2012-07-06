# encoding: UTF-8
#!/usr/bin/env ruby

# USAGE:
# Set credentials in credentials.yml file
# Run: GOOGLE_PASSWORD=your-password ruby srug-subscribers.rb

require "yaml"
require "csv"
require "pp"
require "google_drive"

raise ArgumentError, "Set GOOGLE_PASSWORD" unless ENV["GOOGLE_PASSWORD"]

credentials = YAML.load_file("credentials.yml")
session = GoogleDrive.login(credentials["google_user"], ENV["GOOGLE_PASSWORD"])

subscriptions = {}
credentials["spreadsheet_keys"].each_with_index do |key, i|
  csv = session.spreadsheet_by_key(key).export_as_string("csv").force_encoding("UTF-8")

  emails = []
  CSV.parse(csv, headers: true) do |row|
    emails << row["Adres e-mail"] unless row["Przypomnienie o następnych spotkaniach"].nil?
  end
  subscriptions[i] = emails
end

unique_emails = subscriptions.values.flatten.uniq

File.open("srug-subscribers.txt", "w") { |f| f.puts unique_emails.join(",") }

pp "Emails count: #{unique_emails.size}"
pp unique_emails
