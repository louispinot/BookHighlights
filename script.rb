require "pry"

class Book
  attr_reader :title, :author
  @@instances = []
  def initialize(title, author)
    @title = title
    @author = author
    @@instances << self
  end

  def self.all
    @@instances
  end

  def self.hide(book_title)
    @@instances.delete_if{|book| book.title == book_title}
  end

end


######################################

class Clipping

  attr_reader :string, :book, :content, :place, :type

  @@instances = []
  def initialize(string)

    @string = string

    # Find or create book instance
    book = Book.all.detect{|book| book.title == parse_title}
    if book.nil?
      book = Book.new(parse_title, parse_author)
    end

    # Initialize clipping properties
    @book = book
    @content = parse_content
    @place = parse_place
    @type = parse_type

    @@instances << self
  end

  def self.all
    @@instances
  end

  def self.books
    books = []
    @@instances.each do |clipping|
      books << clipping.title unless books.include?(clipping.title)
    end
    books
  end

  def author
    self.book.author
  end
  def title
    self.book.title
  end

private
  def parse_author
    string = @string.split(/\r\n/)[0]
    author = string.split(/\(/)[-1][0..-2]
  end
  def parse_title
    string = @string.split(/\r\n/)[0]
    title = string.split(/\(/)[0][0..-2]
  end

  def parse_content
    arr = @string.split(/\r\n/)[3..-1]
    content = ""
    arr.each do |i|
      content += i
    end
    content
  rescue
    "" # when the highlight is empty
  end

  def parse_place
    string = @string.split(/\r\n/)[1]
    string.gsub(/.+emplacement /,"").gsub(/ \| .+/, "").split("-").first
  rescue
    binding.pry
  end

  def parse_type
    string = @string.split(/\r\n/)[1]
    type = string.gsub(/- Votre /, "").split(" ").first
    if type == "note"
      :note
    elsif type == "surlignement"
      :highlight
    elsif type == "signet"
      :bookmark
    else
      raise
    end
  end

end

File.open("My Clippings.txt", "r") do |f|
  cache = ""
  f.each_line do |line|
    if line != "==========\r\n"
      cache += line
    else
      Clipping.new(cache)
      cache = ""
    end
  end
# binding.pry
end

# !!! These books' clippings will not appear !!! #
Book.hide("Cien años de soledad")
Book.hide("Dating on Tinder: A Man's Guide to Hooking up and Having Relationships on Tinder")
Book.hide("Presse-papie")
Book.hide("JavaScript: The Good Parts: The Good Parts")

Book.all.each do |book|
  File.open("Clippings/#{book.title}.md", "w") do |f|
    f << "##{book.title}\n"
    f << "###{book.author}\n"
    f << "-----------------------------\n\n"
    Clipping.all.select {|c| c.book == book}.sort_by {|c| c.place }.each do |c|
      f << "**#{c.place} (#{c.type})**\n\n"
      f << "#{c.content}\n\n\n"
    end
  end
end
