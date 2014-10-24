require 'csv'
require 'rubygems'
require 'twilio-ruby'

class Sandwich
  attr_reader :id, :price, :name, :description
  def initialize(args = {})
    @id = args[:id]
    @name = args[:name]
    @description = args[:description]
    @price = args[:price]
  end
end


class Controller
  attr_reader :sandwich_list, :twilio_message
  def initialize
    @sandwich_list = []
    @view=View.new
    CSV.foreach('menu.csv', headers: true, header_converters: :symbol) do |row|
      @sandwich_list << Sandwich.new(row)
    end
    @exit = false
    @cart = []
    @twilio_message = ""
  end

  def drive
    display_menu
    while @exit != true
      options
      decision
    end
  end

  def display_menu
    @view.render_menu(@sandwich_list)
  end

  def display_cart_remove
    @view.render("YOUR CART")
    @cart.each do |sandwich|
      @view.render("#{sandwich.id} #{sandwich.name} #{sandwich.price}")
    end
  end

  def display_cart
    @view.render("YOUR CART")
    @cart.each do |sandwich|
      @view.render(" - #{sandwich.name} #{sandwich.price}")
    end
    @view.render("Total: #{sum}")
  end

  def sum
    sum = 0
    @cart.each do |sandwich|
      sum += sandwich.price.to_f
    end
    sum.round(2)
  end

  def request_order
    @view.render_order(sandwich_list)
  end

  def options
    @view.render_options
  end

  def add_sandwich
    @view.render_menu(sandwich_list)
    sandwich_name = @view.render_order(sandwich_list)
    @sandwich_list.each do |sandwich|
      if sandwich.name == sandwich_name
        @cart << sandwich
      end
    end
  end

  def remove_sandwich
    target = ""
    display_cart_remove
    @view.render("What number sandwich would you like to remove?")
    sandwich_id = gets.chomp
    @cart.each do |sandwich|
      if sandwich.id == sandwich_id
        target = sandwich
      end
    end
    @cart.delete_at(@cart.find_index(target))
  end

  def prepare_order
    sandwich_cart_hash = {}
    @cart.each do |sandwich|
      if sandwich_cart_hash.has_key?(sandwich.name)
        sandwich_cart_hash[sandwich.name] += 1
      else
        sandwich_cart_hash[sandwich.name] = 1
      end
    end
    sandwich_cart_hash
  end

  def place_order
    sandwich_cart_hash = prepare_order
    sandwich_cart_hash.each do |k,v|
      @twilio_message += "\n#{v}: #{k}"
    end
    @twilio_message
  end

  def twilio_message
    account_sid = "AC27bf9c7c50adfe10a7c0e4660e3e61cd"
    auth_token = "02ecd2a115226c4d817297984e3d1a05"
    client = Twilio::REST::Client.new account_sid, auth_token
    from = "+16506845053"

    friends = {
    "+16505801483" => "Julian",
    "+17034709608" => "Kevin",
    ## Store owner will add more customers/friends here
    # # "+16506363688" => "Henry",
    #"+19098019741" => "Ryan"
    }
    unless @twilio_message.empty?
      friends.each do |key, value|
        client.account.messages.create(
          :from => from,
          :to => key,
          :body => @twilio_message
        )
        puts "Sent message to #{value}"
      end
    end
    @view.render("You must place a sandwich in your cart") if @twilio_message.empty?
  end

  def decision
    choice = gets.chomp.downcase
    case choice
    when 'add'
      add_sandwich
    when 'exit','end'
      @exit = true
    when 'm','menu'
      display_menu
    when 'r','remove'
      remove_sandwich
    when 's','show'
      display_cart
    when 'o','order'
      place_order
      twilio_message
    end
  end

end

class View
  def render_menu(sandwich_list)
    puts
    puts "_______HERE IS THE MENU!!_______"
    puts
    sandwich_list.each do |sandwich|
      puts "Number: #{sandwich.id}    Name: #{sandwich.name}    Price: #{sandwich.price}"
      puts "Description: #{sandwich.description}"
      puts '-'*100
    end
  end
  def render_order(sandwich_list)
    puts "What number sandwich would you like to order?"
    sandwich_order = gets.chomp.to_i
    sandwich_name = sandwich_list[sandwich_order - 1].name
    puts "You selected #{sandwich_name}"
    return sandwich_name
  end
  def render_options
    puts
    puts '-'*100
    puts
    puts "Enter one of the following commands to perform blsdf"
    puts "'Add' - to add another sandwich to the list"
    puts "'Remove' - to remove a sandwich fromt the list"
    puts "'Show' - to show all the sandwiches in the cart"
    puts "'Order' - to place the order"
    puts "'Exit' - to place the exit"
  end
  def render(customized_message)
    puts "#{customized_message}"
  end
end

menu = Controller.new
menu.drive


