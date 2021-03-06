# frozen_string_literal: true

require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'

get '/' do
  erb 'Hello! <a href="https://github.com/bootstrap-ruby/sinatra-bootstrap">Original</a> pattern has been modified for <a href="http://rubyschool.us/">Ruby School</a>'
end

get '/about' do
  erb :about
end

get '/visits' do
  erb :visits
end

post '/visits' do
  @user = params[:user_name]
  @phone = params[:user_phone]
  @date = params[:date_time]
  @barber = params[:barber]
  @colorpicker = params[:colorpicker]
  @message = ''
  @f = File.open('./public/users.txt', 'a+')

  errors_hh = { user_name: 'Введите имя',
                user_phone: 'Введите номер телефона',
                date_time: 'Ведите дату и время' }

  @error = errors_hh.select { |key, _value| params[key] == '' }.values.join(', ')

  return erb :visits if @error != ''

  def is_time_busy?
    @f.each do |line|
      return true if line.include?(@date)
    end

    false
  end

  def is_barber_busy?
    @f.each do |line|
      return true if line.include?(@barber)
    end

    false
  end

  def add_client
    @f.write "User: [#{@user}] -- Phone: [#{@phone}] -- Date time: [#{@date}] -- Barber: [#{@barber}] -- Hair color: [#{@colorpicker}]\n"
  end

  if is_time_busy? && is_barber_busy?

    @message = "Dear, #{@user}! #{@date} is busy :( Try another time."
  else
    add_client
    @message = "Dear, #{@user}! We'll wait you at #{@date}. Your barber - #{@barber}. You choose #{@colorpicker} color for hair."
  end

  @f.close
  erb @message
end

get '/contacts' do
  erb :contacts
end

post '/contacts' do
  @user_mail = params[:user_email]
  @user_msg = params[:user_message]

  @error = 'Введите email' if @user_mail == ''

  @f = File.open('./public/contacts.txt', 'a+')
  @f.write "User mail: [#{@user_mail}] -- Message: [#{@user_msg}]\n"
  @f.close

  Pony.mail ({
    to: 'runemal13@gmail.com',
    from: params[:user_email],
    subject: 'from barbershop',
    body: "User: #{params[:user_email]}\nMessage: #{params[:user_message]}",
    via: :smtp,
    via_options: {
          address: 'smtp.gmail.com',
          port: '587',
          user_name: 'runemal13',
          password: 'dzenMidzeN13',
          authentication: :plain, 
          domain: "gmail.com" 
          } 
     })
  erb :contacts
end
