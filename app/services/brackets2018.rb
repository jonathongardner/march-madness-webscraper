class Brackets2018
  START_BRACKET = 350
  END_BRACKET = 1000000
  MAX_ERRORS = 50
  BATCH_SIZE = 1000
  COLUMNS = [:id, :unique_game_number]
  def initialize
    reset_to_save
    @web_scrapper = WebScrapper.new
    @current_bracket = START_BRACKET
    @current_errors = 0
  end

  def run
    while @current_bracket <= END_BRACKET
      begin
        @to_save.push([@current_bracket, @web_scrapper.unique_game_number(@current_bracket)])
      rescue IdNotFound
        puts "ERROR: Id doesnt exist: #{@current_bracket}"
        @current_errors += 1
      rescue SomeOtherError
        puts "ERROR: Mmmm not sure what happen: #{@current_bracket}"
        @current_errors += 1
      rescue Exception
        puts "ERROR: SHOOT! I really have no idea what happen: #{@current_bracket}"
        @current_errors += 1
      ensure
        puts "Done with #{@current_bracket}..." if @current_bracket % 100 == 0
        save_to_db if @to_save.length >= BATCH_SIZE
        @current_bracket += 1
      end
    end
    save_to_db if to_save.present?
    puts "Finished getting all brackets #{@current_bracket - 1}"
  end

  def save_to_db
    puts "Saving to database (#{to_save[0][0]} to #{to_save[-1][0]})..."
    import_results = B2018.import COLUMNS, to_save, validate: false
    if import_results.failed_instances.present?
      puts "The following ids failed: (#{import_results.failed_instances.map(&:id)})."
    end
    reset_to_save
    puts "Finished Saving!!!"
  end

  private
    def to_save
      @to_save
    end
    def reset_to_save
      @to_save = []
    end
end
