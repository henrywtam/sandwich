require 'csv'

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
  attr_reader :sandwich_list
  def initialize
    @sandwich_list = []
    @view=View.new
    CSV.foreach('menu.csv', headers: true, header_converters: :symbol) do |row|
      @sandwich_list << Sandwich.new(row)
    end
  end

  def drive
    
    display_menu
    request_order
    options
    decision
  end

  def display_menu
    @view.render_menu(sandwich_list)
  end
  def request_order
    @view.render_order(sandwich_list)
  end

  def options
    @view.render_options
  end
  def decision
    choice = gets.chomp.downcase
    if choice == 'add' || choice == 'a'
      @view.render_menu(sandwich_list)
      @view.render_order(sandwich_list)
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
  end
end



menu = Controller.new
menu.drive

