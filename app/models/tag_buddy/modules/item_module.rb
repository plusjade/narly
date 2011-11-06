module TagBuddy
  
  module Item
    include TagBuddy::Base
    
    def self.included(model)
      model.extend(TagBuddy::Base::ClassMethods)
      model.extend(ClassMethods)
      class << model; attr_accessor :namespace, :scope_by_field end
      model.namespace = "ITEM"
    end
    
    
    def tag_by_user(user, tag)
      add_tag_associations(user, self, tag)
    end

    def untag_by_user(user, tag)
      remove_tag_associations(user, self, tag)
    end  

    # Return an Array of Tag instances associated with this Repo.
    # Tags become associated with a repo when a user tags said repo.
    #
    def tags(limit=nil)
      Tag.new_from_tags_data(tags_data(limit))
    end

    # Return an Array of User instances this Repo is attached to.
    # A user is attached to a repo when the user tags said repo.
    #    
    def users(limit=nil)
      ghids = Array($redis.smembers storage_key(:users))
      ghids = ghids[0, limit.to_i] unless limit.to_i.zero?

      User.all(:ghid => ghids).sort! { |x,y|
        ghids.index(x.id) <=> ghids.index(y.id)
      }
    end

    # Return an Array of Repo instances that share this repo's top 3 tags.  
    # Ideally we want what repos share the top 3 tags in *their* top n tags
    # but that's kind of hard right now.
    #
    def similar_repos(limit=nil)
      keys = tags(3).map {|tag| tag.storage_key(:items) }
      ghids = $redis.send(:sinter, *keys)
      ghids.delete(self.ghid.to_s)
      ghids = ghids[0, limit.to_i] unless limit.to_i.zero?

      Repository.all(:ghid => ghids).sort! { |x,y|
        ghids.index(x.id) <=> ghids.index(y.id)
      }
    end
    
    
    module ClassMethods
      
      def tag_buddy_type
        :item
      end
        
    end # ClassMethods
    
  end # User
  
end # TagBuddy