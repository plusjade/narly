module TagSystem
  StorageDeliminator = ":"

  def self.included(model)
    model.extend(ClassMethods)
    class << model; attr_accessor :namespace, :scope_by_field end
  end
  
  # Record everything needed to make user<->rep tag associations.
  # We use redis to store associations and counts relative to those associations.
  #
  # Notes:
  #   $redis.sadd returns bool for singular value additions.
  #   Bool value reflects whether the insertion was newly added.
  #
  def add_tag_associations(user, repo, tag)
    user = (user.is_a? User)       ? user : User.first(:ghid => user.to_i)
    repo = (repo.is_a? Repository) ? repo : Repository.new(:ghid => repo.to_i)
    tag  = (tag.is_a? Tag)         ? tag  : Tag.new(:name => tag)

    # Add REPO to the USER'S total REPO collection relative to TAG
    is_new_tag_on_repo_for_user = ($redis.sadd user.storage_key_for_tag_repos(tag.name), repo.ghid)

    $redis.multi do
      # Add REPO to the USERS's total REPO collection.
      $redis.sadd user.storage_key(:repos), repo.ghid

      # Add USER to the REPO's total USER collection
      $redis.sadd repo.storage_key(:users), user.ghid
      
      # Add USER to the TAG's total USER collection.
      $redis.sadd tag.storage_key(:users), user.ghid

      # Add REPO to the TAG's total REPO collection.
      $redis.sadd tag.storage_key(:repos), repo.ghid
      
      if is_new_tag_on_repo_for_user
        # Increment the USER's TAG count for TAG
        $redis.zincrby user.storage_key(:tags), 1, tag.name
        
        # Increment the REPO's TAG count for TAG
        $redis.zincrby repo.storage_key(:tags), 1, tag.name
      end
      
      # Add TAG to total TAG collection
      $redis.zincrby "TAGS", 1, tag.name
    end
      
  end
  
  
  # Record everything needed to remove user<->rep tag associations.
  # We use redis to store associations and counts relative to those associations.
  #
  # Notes:
  #   $redis.srem returns bool for singular value additions.
  #   Bool value reflects whether the the key exist before it was removed.
  #
  def remove_tag_associations(user, repo, tag)
    user = (user.is_a? User)       ? user : User.first(:ghid => user.to_i)
    repo = (repo.is_a? Repository) ? repo : Repository.new(:ghid => repo.to_i)
    tag  = (tag.is_a? Tag)         ? tag  : Tag.new(:name => tag)

    # Remove REPO from the USER'S total REPO collection relative to TAG
    was_removed_tag_on_repo_for_user = ($redis.srem user.storage_key_for_tag_repos(tag.name), repo.ghid)

    $redis.multi do
      # Remove REPO from the USERS's total REPO collection.
      $redis.srem user.storage_key(:repos), repo.ghid

      # Remove USER from the REPO's total USER collection
      $redis.srem repo.storage_key(:users), user.ghid
      
      # Remove USER from the TAG's total USER collection.
      $redis.srem tag.storage_key(:users), user.ghid

      # Remove REPO from the TAG's total REPO collection.
      $redis.srem tag.storage_key(:repos), repo.ghid
    end
    
    if was_removed_tag_on_repo_for_user
      # Decrement the USER's TAG count for TAG
      if($redis.zincrby user.storage_key(:tags), -1, tag.name).to_i <= 0
        $redis.zrem user.storage_key(:tags), tag.name
      end
      
      # Decrement the REPO's TAG count for TAG
      if ($redis.zincrby repo.storage_key(:tags), -1, tag.name).to_i <= 0
        $redis.zrem repo.storage_key(:tags), tag.name
      end
    end
      
    # Decrement TAG count in TAG collection
    if ($redis.zincrby "TAGS" -1, tag.name).to_i <= 0
      $redis.zrem "TAGS", tag.name
    end
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
  
  module ClassMethods
    
    def define_tag_strategy(opts={})
      opts[:namespace] ||= ""
      opts[:scope_by_field] ||= ""

      self.namespace = opts[:namespace].to_s
      self.scope_by_field = opts[:scope_by_field].to_s
    end
    
  end # ClassMethods
  
end