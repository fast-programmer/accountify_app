iam_user = { id: 1 }
iam_tenant = { id: 1 }

$running = true

Signal.trap("INT") do
  puts "Shutdown requested, terminating..."

  $running = false
end

while $running
  begin
    organisation, event = Accountify::Organisation
      .create(
        iam_user: iam_user,
        iam_tenant: iam_tenant,
        name: 'Big Bin Corp')

    puts "Created (organisation,event)=(#{organisation[:id]},#{event[:id]}) for #{iam_user[:id]} at #{Time.now}"

    sleep 5
  rescue => e
    puts "An error occurred: #{e.message}"
  end
end

puts "Script has been terminated."
