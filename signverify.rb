require 'openssl'
require 'base64'
require 'optparse'

options   = {}

optparse  = OptionParser.new do |opts|
  opts.banner = "Usage: sslsign [options] file1 file2"

  options[:message] = ''
  opts.on('-m MESSAGE', '--message MESSAGE', 'Sign MESSAGE') do |msg|
    options[:message] = msg
  end

  options[:sigfile] = 'signature.txt'
  opts.on('-o FILE', '--out FILE', 'Write signature to FILE') do |file|
    options[:sigfile] = file
  end

  options[:privfile] = '~/.ssh/id_rsa'
  opts.on('- FILE', '--privfile FILE', 'Get private key from FILE') do |file|
    options[:privfile] = file
  end

  opts.on('-h', '--h', 'Displays this screen') do
    puts opts
    exit
  end
end

optparse.parse!
if options[:message] == ''
  puts 'You must supply a message. Run with -h or --help to seek help'
  exit
end

digest = OpenSSL::Digest::SHA256.new
begin
  pkey = OpenSSL::PKey::RSA.new(File.read(options[:privfile]))
rescue
  puts "Private key could not be loaded!"
  exit
end
signature = pkey.sign(digest, options[:message])

File.open(options[:sigfile], "w") { |file|
  file.write(signature)
}

puts "Message successfully signed!"
puts "Message: #{options[:message]}"
puts "Signature file: #{options[:sigfile]}"
