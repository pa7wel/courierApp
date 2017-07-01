class HardWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(params)

    $data = ActiveSupport::JSON.decode(params)

    $data['cities'].each do |i| 
      city = City.new(i);
      TourManager.add_city(city);
    end

    population = Population.new(500, true)

    @initial_dist = population.fittest.distance
    puts "Initial distance: #{@initial_dist}"

    population = GA.evolve_population( population )
    population = GA.evolve_population( population )
    100.times do
      population = GA.evolve_population( population )
    end

    @final_dist = population.fittest.distance;
    puts "Final distance: #{@final_dist}"
    @solution = population.fittest.to_s
    @solution_array = population.fittest.to_table
    puts "Array solution: #{@solution_array}"
    puts "Final distance: #{@final_dist}"

    store initial_dist: @initial_dist
    initial_dist = retrieve :initial_dist

    store final_dist: @final_dist
    final_dist = retrieve :final_dist

    store solution: @solution
    solution = retrieve :solution

    store solution_array: @solution_array.to_json
    solution_array = retrieve :solution_array

  end

class City
  attr_accessor :name

  def initialize( name = nil)
    self.name = name
  end

  def distance_to( city )
    @miasta = $data['distances'].values
    @distance = @miasta.find {|x| x['origin'] == name  and x['destination'] == city.name}['distance']
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
    @fitness = @distance = 0
  end

  def fitness
    if @fitness == 0
      @fitness = 1 - (10000.0/distance)
    end
    puts "Funkcja fitness: #{@fitness}"
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
    tours.max_by{ |t| t.fitness }
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

    if should_initialize 
      population_size.times do
        new_tour = Tour.new  
        new_tour.generate_individual
        tours << new_tour
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
    0.3
  end

  def self.tournament_size
    5
  end

  def self.elitism
    true
  end

  def self.evolve_population( population )
    new_population = Population.new( population.size, false )

    elitism_offset = 0
    if elitism
      new_population.save_tour(0, population.fittest) 
      elitism_offset = 1
    end

    (elitism_offset...population.size).each do |i|
      parent1 = tournament_selection( population )
      parent2 = tournament_selection( population )  

      child = crossover( parent1, parent2 )
      new_population.save_tour(i, child)
    end

    new_population.each(elitism_offset) do |tour|
      mutate(tour)
    end

    new_population
  end

  def self.crossover( parent1, parent2)
    child = Tour.new

    start_pos = Integer(rand * parent1.size)
    end_pos = Integer(rand * parent2.size)

    parent1_genes = []
    parent2_genes = []
    (0...child.size).each do |i|
      if start_pos < end_pos && i > start_pos && i < end_pos
        parent1_genes << i
        child.set_city( i, parent1.get_city(i) )
      elsif start_pos > end_pos
        if !(i < start_pos && i > end_pos)
          parent1_genes << i
          child.set_city(i, parent1.get_city(i) )
        end
      end
    end

    parent2.each_with_index do |city, index|
      if !child.contains_city?( city )
        parent2_genes << child.set_at_first_available( city )
      end
    end

    child
  end

  def self.mutate( tour )
    (0...tour.size).each do | tourPos1 |
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
    tournament = Population.new( tournament_size, false)
    (0...tournament_size).each do |index|
      random_index = Integer(rand * population.size)
      tournament.save_tour(index, population.get_tour( random_index ) )
    end
    tournament.fittest
  end
end
end



