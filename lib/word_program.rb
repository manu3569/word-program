
# Author: Manuel Neuhauser

class WordProgram

  def initialize(source_file)
    @content = File.read(source_file)
    process_content
    process_user_input
  end

  private

    def process_user_input
      puts "To exit hit CTRL+C\n\n"
      while true
        display_formatted(Sentence.find(input))
      end
    end

    def input
      print "Find sentences starting with: "
      gets.strip
    end

    def process_content
      @content.split(". ").each do |sentence|
        Sentence.new(sentence)
      end
    end

    private

      def display_formatted(sentence_list)
        puts " *** No matching sentences found ***\n" if sentence_list.empty?
        sentence_list.each_with_index do |sentence, idx|
          puts "#{idx+1}. #{sentence}"
        end
        puts ""
        puts ""
      end

end


class Sentence

  attr_reader :text

  # Automatically creates new child hash if key doesn't exist
  @@db = Hash.new{|hash, key| hash[key] = Hash.new(&hash.default_proc) }

  def initialize(text)
    @text = clean(text)
    add_to_db
  end

  def self.find(sentence_fragment)
    current = @@db
    self.make_symbols(sentence_fragment).each do |symbol|
      if current.has_key?(symbol)
        current = current[symbol]
      else
        return []
      end
    end
    self.extract_sentences(current, [])
  end

  def self.extract_sentences(current, collection)
    current.each do |key, value|
      if key == :FULL_SENTENCE
        collection << value.text
      else
        return collection if collection.size == 10
        collection = self.extract_sentences(value, collection)
      end
    end
    collection
  end

  def self.make_symbols(text)
    text.downcase.scan(/\w+/i).map(&:to_sym)
  end

  private

    def clean(text)
      text.gsub(/(\r?\n)| +/, " ")
    end

    def add_to_db
      current = @@db
      Sentence.make_symbols(@text).each do |symbol|
        current = current[symbol]
      end
      current[:FULL_SENTENCE] = self
    end

end


SOURCE = 'data/strange-case-of-dr-jekyll-and-mr-hyde.txt'
WordProgram.new(SOURCE)