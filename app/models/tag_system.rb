module TagSystem
  StorageDeliminator = ":"
  
  # These are instance methods that get included on all 3 models.
  #
  module Base
    
    def get_tagging_system_type
      self.class.tagging_system_type
    end
  
    # Record everything needed to make user<->rep tag associations.
    # We use redis to store associations and counts relative to those associations.
    #
    # Notes:
    #   $redis.sadd returns bool for singular value additions.
    #   Bool value reflects whether the insertion was newly added.
    #
    def add_tag_associations(*args)
      data = {}
      args.each { |o| data[o.get_tagging_system_type.to_sym] = o }
    
      # Add ITEM to the USER'S total ITEM data relative to TAG
      is_new_tag_on_item_for_user = ($redis.sadd data[:user].storage_key_for_tag_repos(data[:tag].scoped_field), data[:item].scoped_field)

      $redis.multi do
        # Add ITEM to the USERS's total ITEM data.
        $redis.sadd data[:user].storage_key(:items), data[:item].scoped_field

        # Add USER to the ITEM's total USER data
        $redis.sadd data[:item].storage_key(:users), data[:user].scoped_field
      
        # Add USER to the TAG's total USER data.
        $redis.sadd data[:tag].storage_key(:users), data[:user].scoped_field

        # Add ITEM to the TAG's total ITEM data.
        $redis.sadd data[:tag].storage_key(:items), data[:item].scoped_field
      
        if is_new_tag_on_item_for_user
          # Increment the USER's TAG count for TAG
          $redis.zincrby data[:user].storage_key(:tags), 1, data[:tag].scoped_field
        
          # Increment the ITEM's TAG count for TAG
          $redis.zincrby data[:item].storage_key(:tags), 1, data[:tag].scoped_field
        end
      
        # Add TAG to total TAG data
        $redis.zincrby data[:tag].class.namespace , 1, data[:tag].scoped_field

      end

      # Add TAG to USER's tag data relative to ITEM
      # (this is kept in a dictionary to save memory)
      tag_array = data[:user].tags_on_repo_as_array(data[:item])
      tag_array.push(data[:tag].scoped_field).uniq!
      $redis.hset data[:user].storage_key(:items, :tags), data[:item].scoped_field, ActiveSupport::JSON.encode(tag_array)

    end
  
    # Record everything needed to remove user<->item tag associations.
    # We use redis to store associations and counts relative to those associations.
    #
    # Notes:
    #   $redis.srem returns bool for singular value additions.
    #   Bool value reflects whether the the key exist before it was removed.
    #
    def remove_tag_associations(*args)
      data = {}
      args.each { |o| data[o.get_tagging_system_type.to_sym] = o }
    
      # Remove ITEM from the USER'S total ITEM data relative to TAG
      was_removed_tag_on_item_for_user = ($redis.srem data[:user].storage_key_for_tag_repos(data[:tag].scoped_field), data[:item].scoped_field)

      $redis.multi do
        # Remove ITEM from the USERS's total ITEM data.
        $redis.srem data[:user].storage_key(:items), data[:item].scoped_field

        # Remove USER from the ITEM's total USER data
        $redis.srem data[:item].storage_key(:users), data[:user].scoped_field
      
        # Remove USER from the TAG's total USER data.
        $redis.srem data[:tag].storage_key(:users), data[:user].scoped_field

        # Remove ITEM from the TAG's total ITEM data.
        $redis.srem data[:tag].storage_key(:items), data[:item].scoped_field
      end
    
      if was_removed_tag_on_item_for_user
        # Decrement the USER's TAG count for TAG
        if($redis.zincrby data[:user].storage_key(:tags), -1, data[:tag].scoped_field).to_i <= 0
          $redis.zrem data[:user].storage_key(:tags), data[:tag].scoped_field
        end
      
        # Decrement the ITEM's TAG count for TAG
        if ($redis.zincrby data[:item].storage_key(:tags), -1, data[:tag].scoped_field).to_i <= 0
          $redis.zrem data[:item].storage_key(:tags), data[:tag].scoped_field
        end
      end
      
      # Decrement TAG count in TAG data
      if ($redis.zincrby data[:tag].class.namespace, -1, data[:tag].scoped_field).to_i <= 0
        $redis.zrem data[:tag].class.namespace, data[:tag].scoped_field
      end
    
      # REMOVE TAG from USER's tag data relative to ITEM
      # (this is kept in a dictionary to save memory)
      tag_array = data[:user].tags_on_repo_as_array(data[:item])
      tag_array.delete(data[:tag].scoped_field)
      $redis.hset data[:user].storage_key(:items, :tags), data[:item].scoped_field, ActiveSupport::JSON.encode(tag_array)
    end
  
  
    # Create and return the storage key for the calling resource.
    # Namespace and scoping field is applied.
    #
    def storage_key(*args)
      args.unshift(
        self.class.namespace,
        self.send(self.class.scope_by_field)
      ).map! { |v| 
        v.to_s.gsub(StorageDeliminator, "") 
      }.join(StorageDeliminator)
    end

  
    # returns array with tag_name, score.
    # ex: ["ruby", "1", "git", "1"] 
    #
    def tags_data(limit=nil)
      $redis.zrevrange( 
        self.storage_key(:tags),
        0, 
        (limit.to_i.nil? ? -1 : limit.to_i - 1),
        :with_scores => true
      )
    end
  
    # Return the field we are scoping on for this model instance.
    #
    def scoped_field
      self.send(self.class.scope_by_field)
    end
  
  end # Base
  
  
  module Tag
    include Base
    
    def self.included(model)
      puts "yay im being included"

      model.extend(BaseClassMethods)
      model.extend(ClassMethods)
      
      class << model; attr_accessor :tagging_system_type, :namespace, :scope_by_field end
      model.tagging_system_type = :tag
    end

    def tag_by_user_repo(user, repo)
      add_tag_associations(user, repo, self)
    end

    def untag_by_user_repo(user, repo)
      remove_tag_associations(user, repo, self)
    end
    
    # Return an Array of User instances this tag is associated with.
    # A user is attached to a tag when the user tags a repo with said tag.
    #
    def users(limit = nil)
      ghids = Array($redis.smembers storage_key(:users))
      ghids = ghids[0, limit.to_i] unless limit.to_i.zero?

      User.all(:ghid => ghids).sort! { |x,y| 
        ghids.index(x.id) <=> ghids.index(y.id)
      }
    end
        
    # Get repos this tag is attached to.
    #  
    def repos(limit = nil)
      names = Array($redis.smembers storage_key(:items))
      # define sorting in redis.
      names = ghids[0, limit.to_i] unless limit.to_i.zero?

      Repository.all(:full_name => names).sort! { |x,y|
        names.index(x.id) <=> names.index(y.id)
      }
    end
    
    module ClassMethods
      
      # Get all Tags
      #
      def all(limit=nil)
        self.new_from_tags_data(
          $redis.zrevrange( 
            self.namespace,
            0, 
            (limit.to_i.nil? ? -1 : limit.to_i - 1),
            :with_scores => true
          )
        )
      end
        
      
      # Spawn Tag instances from the given tag_string
      # where tag_string is a String of the format:
      #   tag1:tag2:tag3:tagN:...
      # This format is used in the url as paramater
      #
      def new_from_tag_string(tag_string)
        tag_string.to_s.split(":").map do |name|
          new(:name => name)
        end
      end

      # Return an Array of Repository instances associated with the provided tags.
      # tags can be one or an Array of Tag instances or a tag_string
      #
      def repos(tags, limit = nil)
        tags = case tags
        when String
          new_from_tag_string(tags)
        else
          Array(tags)
        end

        keys = tags.map { |tag| tag.storage_key(:items) }
        ghids = $redis.send(:sinter, *keys)
        ghids = ghids[0, limit.to_i] unless limit.to_i.zero?

        Repository.all(:ghid => ghids).sort! { |x,y| 
          ghids.index(x.id) <=> ghids.index(y.id)
        }
      end

      # tags_data format: 
      #   ["ruby", "1", "git", "1"] 
      #   where scores represent tag count and come directly after their tag.
      #
      def new_from_tags_data(tags_data)
        tags = []
        tags_data.each_with_index do |name, i|
    			next if (i > 0 && i.odd?)
          tags << new(:name => name, :relative_count => tags_data[i+1])
        end

        tags
      end  

      # Takes one or more Tag instances (via array) and provides
      # the equivalent tag_string
      #
      def to_tag_string(tags)
        Array(tags).map! { |tag| tag.name }.join(":")
      end
        
        
    end # TagClassMethods
      
    
  end
  
  module User
    include Base
    
    def self.included(model)
      puts "yay im being included"

      model.extend(BaseClassMethods)
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
  
  module Item
    include Base
    
    def self.included(model)
      puts "yay im being included"

      model.extend(BaseClassMethods)
      model.extend(ClassMethods)
      class << model; attr_accessor :tagging_system_type, :namespace, :scope_by_field end
      model.tagging_system_type = :item
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
      
      
    end
    
  end
  
  module BaseClassMethods
    
    def define_tag_strategy(opts={})
      opts[:namespace] ||= ""
      opts[:scope_by_field] ||= ""
      
      self.namespace = opts[:namespace].to_s
      self.scope_by_field = opts[:scope_by_field].to_s
    end
    
  end # BaseClassMethods
  
end