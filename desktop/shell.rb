require 'highline'
require 'cli-console'
require 'typhoeus'
require 'json'
require 'arduino_firmata'

require_relative 'trial'

class ShellUI < HighLine
    
    private
    extend CLI::Task

    def token_request(email, password)
        request = Typhoeus::Request.new(
          "localhost:3000/tokens.json",
          method:        :post,
          body:          "email=#{email}&password=#{password}",      
        )
        request.run
        response = request.response
        if response.code == 200
            return JSON.parse(response.body)
        else
            return nil
        end
    end

    def new_trial
        name = ask("Title: ", String)
        date = DateTime.now
        trial = Trial.new(name, date, @credentials[:user_id])
        request = Typhoeus::Request.new(
          "http://localhost:3000/trials.json?auth_token=#{@credentials[:token]}",
          method:        :post,
          body:        trial.to_params.to_json, 
          headers:        {"Content-Type" => "application/json"}
        )
        request.run
        response = JSON.parse(request.response.body)
        return response["id"]
    end  

    public
    
    usage 'Usage: login'
    desc 'Get authetication token from API'
    def login(params)
        email = ask("Login:", String)
        password = ask("Enter your password:", String) { |q| q.echo = "x" }
        if token_request(email, password)
            token = token_request(email, password) 
            @credentials = { email: email, password: password, token: token["token"], user_id: token["user_id"] }
            puts "Logged in as #{email} #{token["user_id"]}"
        else 
            puts "Login failed"
        end
    end

    



    usage 'Usage: start_trial'
    desc 'Start new trial and post it to the server'
    def start_trial(params)
        trial = new_trial
        puts "Loading arduino .."
        arduino = ArduinoFirmata.connect
        hydra = Typhoeus::Hydra.new
        t = Thread.new do
        until gets.chomp == "stop"; end
          # "Label" this thread finished
          Thread.current[:should_stop] = true
        end
        grades = []
        measurements = []
        puts "Program started"
        loop do
            sleep 2
            arduino.on :analog_read do |pin, value|
                if pin == 0
                    if grades.count == 30
                        sum = 0
                        grades.each {|grade| sum = sum + grade }
                        grades.clear
                        measurements << {"measurement" => {"grade" => sum/30, "date" => DateTime.now.httpdate, "trial_id" => trial}}         
                    else
                        grades << value
                        puts grades.count
                    end
                end
            end
            measurements.each do |measurement|
            request = Typhoeus::Request.new(
                          "http://localhost:3000/measurements.json?auth_token=#{@credentials[:token]}",
                          method:        :post,
                          body:           measurement.to_json, 
                          headers:        {"Content-Type" => "application/json"}
                        )
                        hydra.queue request
            end
            hydra.run
            measurements.clear
            # Exit the loop if the listening thread has been "marked" as finished
            break if t[:should_stop]
        end 

    end

    usage 'Usage: cd <Directory>'
    desc 'Change current directory'
    def cd(params)
        trial = new_trial
        puts trial
    end

end

io = HighLine.new
shell = ShellUI.new
console = CLI::Console.new(io)

console.addCommand('login', shell.method(:login), 'User authetication')
console.addCommand('start_trial', shell.method(:start_trial), 'Start monitoring hand movement')
console.addCommand('cd', shell.method(:cd), 'Change directory')
console.addHelpCommand('help', 'Help')
console.addExitCommand('exit', 'Exit from program')
console.addAlias('quit', 'exit')

console.start("> ",[Dir.method(:pwd)])
