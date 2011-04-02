module CreateTagsHelper
  module TagsExtractorMethod
    def extract_tags_from(path)
      tags = []
      tags << File.basename(path,".feature")
      directories_chain = File.dirname(path).split("/")
      directories_chain.delete "features"
      directories_chain.each{|directory| tags << directory}
      tags
    end
  end
end
