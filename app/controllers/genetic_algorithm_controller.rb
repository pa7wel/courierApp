class GeneticAlgorithmController < ApplicationController
   #before_action :start

  def index
  	start
  end

#require './city'
#require './tour'
#require './tour_manager'
#require './population'
#require './ga'
def start
city = City.new(60, 200);  
TourManager.add_city(city);
city2 = City.new(180, 200);
TourManager.add_city(city2);
city3 = City.new(80, 180);
TourManager.add_city(city3);
city4 = City.new(140, 180);
TourManager.add_city(city4);
city5 = City.new(20, 160);
TourManager.add_city(city5);
city6 = City.new(100, 160);
TourManager.add_city(city6);
city7 = City.new(200, 160);
TourManager.add_city(city7);
city8 = City.new(140, 140);
TourManager.add_city(city8);
city9 = City.new(40, 120);
TourManager.add_city(city9);
city10 = City.new(100, 120);
TourManager.add_city(city10);
city11 = City.new(180, 100);
TourManager.add_city(city11);
city12 = City.new(60, 80);
TourManager.add_city(city12);
city13 = City.new(120, 80);
TourManager.add_city(city13);
city14 = City.new(180, 60);
TourManager.add_city(city14);
city15 = City.new(20, 40);
TourManager.add_city(city15);
city16 = City.new(100, 40);
TourManager.add_city(city16);
city17 = City.new(200, 40);
TourManager.add_city(city17);
city18 = City.new(20, 20);
TourManager.add_city(city18);
city19 = City.new(60, 20);
TourManager.add_city(city19);
city20 = City.new(160, 20);
TourManager.add_city(city20);
city21 = City.new(40, 120);
TourManager.add_city(city21);
city22 = City.new(160, 30);
TourManager.add_city(city22);
city23 = City.new(40, 60);
TourManager.add_city(city23);
city24 = City.new(120, 30);
TourManager.add_city(city24);
city25 = City.new(17, 122);
TourManager.add_city(city25);
city26 = City.new(38, 49);
TourManager.add_city(city26);
city27 = City.new(178, 32);
TourManager.add_city(city27);
city28 = City.new(29, 24);
TourManager.add_city(city28);
city29 = City.new(47, 32);
TourManager.add_city(city29);
city30 = City.new(50, 20);
TourManager.add_city(city30);


# Initialize population
population = Population.new(100, true)		# utworzenie populacji skladajacej sie z 100 tras
#puts "Initial distance: #{population.fittest.distance}"  # wyswietlenie najkrotszej trasy na podst. fitness 
@initial_dist = population.fittest.distance
# Evolve population
population = GA.evolve_population( population )
population = GA.evolve_population( population )
100.times do
  population = GA.evolve_population( population )
end

#puts "Finished"
#puts "Final distance: #{population.fittest.distance}"
#puts "Solution:"
#puts population.fittest.to_s
@final_dist = population.fittest.distance;
@solution = population.fittest.to_s
end

# other ...
class City
  attr_accessor :x
  attr_accessor :y

  def initialize( x = nil, y = nil)
    self.x = x
    self.y = y
  end

  def distance_to( city )
    x_distance = (self.x - city.x).abs
    y_distance = ( self.y - city.y).abs
    Math.sqrt( x_distance.abs2 + y_distance.abs2 )
  end

  def to_s
    "#{self.x}, #{self.y}"
  end
end

# class TOUR MANAGER 

class TourManager
  def self.destination_cities
    @destination_cities ||= []
  end

  def self.add_city( city )
    destination_cities << city
  end

  def self.get_city( index )
    destination_cities[ index ]
  end

  def self.number_of_cities
    destination_cities.size
  end

  def self.each_city
    destination_cities.each do |city|
      yield city
    end
  end
end

# class 
class Tour
  def initialize( tour = nil )
    if tour
      set_tour( tour )
    else
      reset_tour
    end
  end

  def generate_individual
    set_tour
    # Loop through all our destination cities and add them to our tour
    TourManager.each_city do |city|
      tour << city
    end
    # randomly reorder the tour
    shuffle_tour!


  end

  def set_at_first_available( city )
    index = tour.index( nil )
    raise "No available spot left in tour! #{to_s}" unless index
    tour[index] = city
    index
  end

  def get_city( tour_position )
    tour[ tour_position ]
  end

  def set_city( tour_position, city )
    tour[tour_position] = city

    # reset cached fitness and distance
    @fitness = @distance = 0
  end

  def fitness
    if @fitness == 0
      @fitness = 1.0/distance
    end
    @fitness
  end

  def distance
    if @distance == 0
      tour_distance = 0
      tour.each_with_index do |city, index|
        from_city = city
        if index + 1 < size
          destination_city = get_city(index+1)
        else
          # If it is the last city in the turn, set
          # the first city as the destination
          destination_city = get_city(0)
        end

        tour_distance += from_city.distance_to(destination_city)
      end
      @distance = tour_distance
    end

    @distance
  end

  def contains_city?( city )
    tour.include?( city )
  end

  def each_with_index(&block)
    tour.each_with_index &block
  end

  def to_s
    gene_string = "|"
    tour.each do |city|
      gene_string << "#{city}|"
    end
    "#{gene_string} => #{distance}"
  end

  def size
    @tour.size
  end

  private
  def tour
    @tour
  end

  def shuffle_tour!
    @tour = tour.shuffle
  end

  def set_tour( tour = [])
    @fitness = 0
    @distance = 0
    @tour = tour
  end

  def reset_tour
    set_tour
    TourManager.number_of_cities.times { |i| tour << nil }
  end
end

# class 

class Population
  attr_accessor :size

  def initialize( population_size, should_initialize)
    initialize_population(population_size, should_initialize)
  end

  def get_tour( index )
    tours[index]
  end

  def fittest
    tours.max_by{ |t| t.fitness }   # wybiermayta trase gdzie funkcja fitness jest najwyzsza tzn. ta trasa jest najkrotsza
  end

  def save_tour( index, tour )
    tours[index] = tour
  end

  def each( offset )
    tours.each_with_index do |tour, index|
      next if index < offset
      yield tour
    end
  end

  private
  def initialize_population( population_size, should_initialize = false)
    @size = population_size     # wielkosc populacji tj. 100
    reset_tours

    if should_initialize             # true - inicjalizujemy wielkosc populacji tj. 100 a kazda zawiera trase tj. ABCD miasta potasowane
      population_size.times do
        new_tour = Tour.new           # utworzenie nowej trasy
        new_tour.generate_individual   # dodanie wszystkich miast i przetasowanie
        tours << new_tour                 # dodanie do TRAS -> obiektu jednej trasy
      end
    end

  end

  def tours
    @tours
  end

  def reset_tours
    @tours = []
  end
end

#class

class GA
  def self.mutation_rate
    0.015
  end

  def self.tournament_size  
    5
  end

  def self.elitism
    true
  end

  def self.evolve_population( population )
    new_population = Population.new( population.size, false )

    # if elitism is enabled we keep the best individual 
    # operator SELEKCJI elitism
    elitism_offset = 0
    if elitism
      #puts "Saving fittest: #{population.fittest.distance}"
      new_population.save_tour(0, population.fittest) # tworzymy nowa populacja z najlepszym wynikiem trasy
      #puts "populacja nowa: #{new_population.fittest}"
      elitism_offset = 1
    end

    # Crossover population operator KRZYZOWANIA
    # Loop over the new population's size
    (elitism_offset...population.size).each do |i|
      # Select parents
      parent1 = tournament_selection( population )  # rodzic 1 = z 5 losowyvh tras populacji wybioramy najkrotsza
      parent2 = tournament_selection( population )  # rodzic 2 = ...

      # Crossover parents -> krzyzowanie crossover -> dzieci rodzicow
      child = crossover( parent1, parent2 )
      new_population.save_tour(i, child)
    end

    # Mutate the new population a bit to add some new genetic material
    new_population.each(elitism_offset) do |tour|
      mutate(tour)
    end

    new_population
  end

  # Applies crossover of random genes and creates offspring
  def self.crossover( parent1, parent2)
    child = Tour.new  # definiowanie dziecka jako nowa trasa

    # Get random start and end sub tour positions for parent1's tour
    start_pos = Integer(rand * parent1.size)  # size = 30
    end_pos = Integer(rand * parent2.size)

    parent1_genes = []
    parent2_genes = []
    # Loop and add the sub tour from parent1 to our child
    (0...child.size).each do |i|
      # if our start position is less than the end position
      if start_pos < end_pos && i > start_pos && i < end_pos
        parent1_genes << i
        # puts "genes: #{parent1_genes}"
        child.set_city( i, parent1.get_city(i) )
      elsif start_pos > end_pos # if it is larger
        if !(i < start_pos && i > end_pos)
          parent1_genes << i
          child.set_city(i, parent1.get_city(i) )
        end
      end
    end

    # Loop through parent2's city tour
    parent2.each_with_index do |city, index|
      if !child.contains_city?( city )
        parent2_genes << child.set_at_first_available( city )
      end
    end

    child
    #puts "dziecko #{child}"
  end

  # Mutate a tour using swap mutation
  def self.mutate( tour )
    (0...tour.size).each do | tourPos1 |
      # Apply mutation rate
      if rand < mutation_rate
        tourPos2 = Integer( rand * tour.size)

        city1 = tour.get_city( tourPos1 )
        city2 = tour.get_city( tourPos2 )

        tour.set_city( tourPos2, city1 )
        tour.set_city( tourPos1, city2 )
      end
    end
  end

  def self.tournament_selection( population )
    # Create a tournament population
    tournament = Population.new( tournament_size, false)

    # For each place in the tournament get a random candidate tour and and it
    # losujemy z populacji 5 tras i zapisujemy do tablicy tournament
    (0...tournament_size).each do |index|
      random_index = Integer(rand * population.size)
      tournament.save_tour(index, population.get_tour( random_index ) )
    end
    # zwracamy najlepszy wynik z fitness
    tournament.fittest
  end
end



end
