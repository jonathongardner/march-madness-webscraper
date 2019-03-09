class WebScrapper
  BRACKET_MAPPING = [
    [ 64,  1], [ 65,  1], [ 66,  1], [ 67,  1], [ 68,  1], [ 69,  1], [ 70,  1], [ 71,  1],
    [ 72,  1], [ 73,  1], [ 74,  1], [ 75,  1], [ 76,  1], [ 77,  1], [ 78,  1], [ 79,  1],
    [ 95,  1], [ 94,  1], [ 93,  1], [ 92,  1], [ 91,  1], [ 90,  1], [ 89,  1], [ 88,  1],
    [ 87,  1], [ 86,  1], [ 85,  1], [ 84,  1], [ 83,  1], [ 82,  1], [ 81,  1], [ 80,  1],
    [ 96,  2], [ 97,  2], [ 98,  2], [ 99,  2], [100,  2], [101,  2], [102,  2], [103,  2],
    [111,  2], [110,  2], [109,  2], [108,  2], [107,  2], [106,  2], [105,  2], [104,  2],
    [112,  4], [113,  4], [114,  4], [115,  4], [119,  4], [118,  4], [117,  4], [116,  4],
    [120,  8], [121,  8], [123,  8], [122,  8], [124, 16], [125, 16], [126, 32],
  ]

  def initialize(url: 'http://fantasy.espn.com/tournament-challenge-bracket/2018/en/entry?entryID=')
    @url = url
  end

  def unique_game_number(id)
    return 5050509827861135890
    doc = Net::HTTP.get(uri(id))
    parsed_page = Nokogiri::HTML(doc)

    raise IdNotFound if parsed_page.at('title')&.content&.downcase == 'moved temporarily'

    winner_ids = []

    parsed_page.search('div.slots > div.slot').each do |slot|
      winner_ids[slot['data-slotindex'].to_i] = slot['data-teamid'].to_i
    end

    champion = parsed_page.at('div.champion > div.slot')
    winner_ids[champion['data-slotindex'].to_i] = champion['data-teamid'].to_i

    binary_string = ''
    BRACKET_MAPPING.each do |game, mod|
      binary_string.prepend(binary_for(winner_ids[game], mod))
    end
    binary_string.to_i(2)
  end

  private
    def binary_for(winner_id, mod)
      ( ( ( winner_id - 1 ) / mod ).floor ) % 2 == 0 ? '0' : '1'
    end

    def uri(id)
      URI("#{@url}#{id}")
    end

end
