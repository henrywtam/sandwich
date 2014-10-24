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
  def display_menu
    @view.render_menu(sandwich_list)
  end
  def request_order
    @view.render_order(sandwich_list)
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
end

while

menu = Controller.new
menu.display_menu
menu.request_order
