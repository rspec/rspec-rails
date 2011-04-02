module CreateTagsHelper
  class FeatureArchive
    attr_reader :content

    def self.build_from(path)
      path_origin = path
      content = File.readlines path
      new(content,path_origin)
    end
    
    def initialize(content,path)
      @content = content
      @path_origin = path
    end

    def add_tag!(tagname)
      @content.insert(0,"@#{tagname}\n")
    end

    def have_tag?(tagname)
      @content.each do |line|
        return false if line.include?("Feature:")
        return true if line.include?("@#{tagname}")
      end
    end

    def try_add_tag!(tagname)
      if self.have_tag?(tagname)
        puts "@#{tagname} already exists in #{@path_origin}"
      else
        self.add_tag! tagname
      end
    end

    def try_add_all_tags!(tags)
      tags.each do |tagname|
        self.try_add_tag!(tagname)
      end
    end

    def save!
      begin
        file = File.open(@path_origin,"w")
        file << @content.join
      ensure
        file.close
      end
    end
  end
end
