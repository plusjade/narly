module TagBuddy

  module User
    include TagBuddy::Base
    
    def self.included(model)
      puts "yay im being included"

      model.extend(TagBuddy::Base::ClassMethods)
      model.extend(ClassMethods)
      class << model; attr_accessor :tagging_system_type, :namespace, :scope_by_field end
      model.tagging_system_type = :user
    end
    
    # Get repos tagged by this user.
    # tags is a single or an array of Tag instances
    def repos_by_tags(tags, limit = nil)
      tags = Array(tags)
      keys = tags.map { |tag| self.storage_key_for_tag_repos(tag.name) }
      ghids = $redis.send(:sinter, *keys)

      # The default repo search should be via the "watched" tag.
      # If there are no repos tagged "watched" for this user it means we haven't loaded this user yet.
      # So we load the user's watched repos from github but only in this default case.
      #
      if (ghids.blank? && tags.count == 1 && tags.first.name == "watched")
        ghids = self.import_watched
      end

      ghids = ghids[0, limit.to_i] unless limit.to_i.zero?

      Repository.all(:full_name => ghids, :order => [:full_name])
    end

    # Get a count of repos tagged with given tag by the given user
    # Tag is a single Tag instance
    #
    def repos_count(tag)
      (tag.is_a?(Tag) ? ($redis.zscore self.storage_key(:tags), tag.name) : 0).to_i
    end

    def tags(limit=nil)
      self.new_from_tags_data(tags_data(limit))
    end

    # Tag a repo with the given tag
    # tag is a Tag instance.
    #
    def tag_repo(repo, tag)
      add_tag_associations(self, repo, tag)
    end

    def untag_repo(repo, tag)
      remove_tag_associations(self, repo, tag)
    end

    def tags_on_repo(repo)
      tags_on_repo_as_array(repo).map do |name|
        self.new(:name => name)
      end
    end

    def tags_on_repo_as_array(repo)
      tag_array = $redis.hget self.storage_key(:items, :tags), repo.ghid
      tag_array = tag_array ? ActiveSupport::JSON.decode(tag_array) : []

      tag_array.sort!
    end

    def storage_key_for_tag_repos(tag)
      storage_key(:tag, tag, :items)
    end
    
    
    module ClassMethods
      
    end
    
    
  end
  
  
end