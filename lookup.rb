def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")
def parse_dns(dns_raw)
  dns_records_data = dns_raw.select { |line| line[0] != "#" && line[0] != "\n"}
  dns_hash = {}
  dns_records_data.each{ |line|
    line_split= line.split(", ").map(&:strip)
    dns_hash[line_split[1]] = {type: line_split[0], target: line_split[2]}
  }
  return dns_hash
end

def resolve(dns_records_hash, lookup_chain, domain)
  value = dns_records_hash[domain]
  if (!value)
    lookup_chain<< "Error: Value not found for "+ domain
  elsif value[:type] == "CNAME"
    lookup_chain.push(value[:target])
    resolve(dns_records_hash, lookup_chain, value[:target])
  elsif value[:type] == "A"
    lookup_chain.push(value[:target])
    return lookup_chain
  else
    lookup_chain << "Invalid type for "+ domain
    return
  end
end
# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
