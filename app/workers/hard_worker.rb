class HardWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(params)

    $data = ActiveSupport::JSON.decode(params)

    $data['cities'].each do |i| 
      city = City.new(i);
      TourManager.add_city(city);
    end
    # Initialize population
    population = Population.new(100, true)
    #puts "Initial distance: #{population.fittest.distance}"  # wyswietlenie najkrotszej trasy na podst. fitness 
    @initial_dist = population.fittest.distance
    puts "Initial distance: #{@initial_dist}"
    # Evolve population
    population = GA.evolve_population( population )
    population = GA.evolve_population( population )
    100.times do
      population = GA.evolve_population( population )
      puts "Final distance: #{population.fittest.distance}"
    end

    @final_dist = population.fittest.distance;
    puts "Final distance: #{@final_dist}"
    @solution = population.fittest.to_s
    puts "Final distance: #{@solution}"
    @solution_array = population.fittest.to_table
    puts "Array solution: #{@solution_array}"

    store initial_dist: @initial_dist
    initial_dist = retrieve :initial_dist

    store final_dist: @final_dist
    final_dist = retrieve :final_dist

    store solution: @solution
    solution = retrieve :solution

    
    store solution_array: @solution_array.to_json
    solution_array = retrieve :solution_array


  end

# CLASSES ---------------------------------------------------------n

class City
  attr_accessor :name

  def initialize( name = nil)
    self.name = name
  end

  def distance_to( city )
    @miasta = $data['distances'].values
    @distance = @miasta.find {|x| x['origin'] == name  and x['destination'] == city.name}['distance']
    #@distance
    #@distance = rand(500)
    #puts "miasto: #{city.name} do #{name} | dystans : #{@distance}"
    @distance.to_i   
  end

  def to_s
    "#{self.name}"
  end
end

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

  def to_table
    array_city = []
    tour.each do |city|
      array_city << city.name
    end
    array_city
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



