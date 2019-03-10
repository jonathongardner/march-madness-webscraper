class Brackets2018
  THREAD_SIZES = 5
  COLUMNS = [:id, :unique_game_number]
  NUMBER_OF_THREADS = 100

  def initialize(start_bracket: 1, final_bracket: nil)
    reset_to_save
    @web_scrapper = WebScrapper.new
    @current_bracket = start_bracket
    @final_bracket = final_bracket || start_bracket + 1000000
  end

  def thread_func(group)
    success = []
    ids_not_found = []
    some_other_error = []
    group.each do |current_bracket|
      begin
        success.push([current_bracket, @web_scrapper.unique_game_number(current_bracket)])
      rescue IdNotFound
        ids_not_found.push(current_bracket)
      rescue SomeOtherError
        some_other_error.push(current_bracket)
      end
    end
    return group, success, ids_not_found, some_other_error
  end

  def run
    kill_file = File.join(Main.root, 'tmp', 'stop')
    while @current_bracket <= @final_bracket && !File.file?(kill_file)
      threads = []
      end_bracket = @current_bracket +  [THREAD_SIZES * NUMBER_OF_THREADS - 1, @final_bracket - @current_bracket].min
      (@current_bracket..end_bracket).each_slice(THREAD_SIZES) do |group|
        threads.push(Thread.new { thread_func(group) })
      end
      threads.each do |thread|
        group, success, ids_not_found, some_other_error = thread.value
        puts "ERROR: Ids not found: #{ids_not_found}" if ids_not_found.present?
        puts "ERROR: Mmmm not sure what happen: #{some_other_error}" if some_other_error.present?
        puts "Done with #{group[0]} - #{group[-1]}..." if
        @to_save.concat(success)
      end
      save_to_db if @to_save.present?
      @current_bracket = end_bracket + 1
    end
    if File.file?(kill_file)
      puts "Stopping from kill file..."
      File.delete(kill_file)
    end
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
