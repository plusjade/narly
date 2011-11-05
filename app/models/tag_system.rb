module TagSystem
  StorageDeliminator = ":"
  
  def self.included(model)
    model.extend(ClassMethods)
    class << model; attr_accessor :tagging_system_type, :namespace, :scope_by_field end
  end
  
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
  def add_tag_associations(user, repo, tag)
    collection = {}
    [user, repo, tag].each do |o|
      collection[o.get_tagging_system_type.to_sym] = o
    end
    
    # Add REPO to the USER'S total REPO collection relative to TAG
    is_new_tag_on_repo_for_user = ($redis.sadd user.storage_key_for_tag_repos(collection[:tag].scoped_field), collection[:item].scoped_field)

    $redis.multi do
      # Add REPO to the USERS's total REPO collection.
      $redis.sadd user.storage_key(:repos), collection[:item].scoped_field

      # Add USER to the REPO's total USER collection
      $redis.sadd repo.storage_key(:users), collection[:user].scoped_field
      
      # Add USER to the TAG's total USER collection.
      $redis.sadd tag.storage_key(:users), collection[:user].scoped_field

      # Add REPO to the TAG's total REPO collection.
      $redis.sadd tag.storage_key(:repos), collection[:item].scoped_field
      
      if is_new_tag_on_repo_for_user
        # Increment the USER's TAG count for TAG
        $redis.zincrby user.storage_key(:tags), 1, collection[:tag].scoped_field
        
        # Increment the REPO's TAG count for TAG
        $redis.zincrby repo.storage_key(:tags), 1, collection[:tag].scoped_field
      end
      
      # Add TAG to total TAG collection
      $redis.zincrby "TAGS", 1, collection[:tag].scoped_field

    end

    # Add TAG to USER's tag collection relative to a repo
    # (this is kept in a dictionary to save memory)
    tag_array = user.tags_on_repo_as_array(repo)
    tag_array.push(collection[:tag].scoped_field).uniq!
    $redis.hset user.storage_key(:repos, :tags), collection[:item].scoped_field, ActiveSupport::JSON.encode(tag_array)

  end
  
  # Record everything needed to remove user<->rep tag associations.
  # We use redis to store associations and counts relative to those associations.
  #
  # Notes:
  #   $redis.srem returns bool for singular value additions.
  #   Bool value reflects whether the the key exist before it was removed.
  #
  def remove_tag_associations(user, repo, tag)
    collection = {}
    [user, repo, tag].each do |o|
      collection[o.get_tagging_system_type] = o
    end
    
    # Remove REPO from the USER'S total REPO collection relative to TAG
    was_removed_tag_on_repo_for_user = ($redis.srem user.storage_key_for_tag_repos(collection[:tag].scoped_field), collection[:item].scoped_field)

    $redis.multi do
      # Remove REPO from the USERS's total REPO collection.
      $redis.srem user.storage_key(:repos), collection[:item].scoped_field

      # Remove USER from the REPO's total USER collection
      $redis.srem repo.storage_key(:users), collection[:user].scoped_field
      
      # Remove USER from the TAG's total USER collection.
      $redis.srem tag.storage_key(:users), collection[:user].scoped_field

      # Remove REPO from the TAG's total REPO collection.
      $redis.srem tag.storage_key(:repos), collection[:item].scoped_field
    end
    
    if was_removed_tag_on_repo_for_user
      # Decrement the USER's TAG count for TAG
      if($redis.zincrby user.storage_key(:tags), -1, collection[:tag].scoped_field).to_i <= 0
        $redis.zrem user.storage_key(:tags), collection[:tag].scoped_field
      end
      
      # Decrement the REPO's TAG count for TAG
      if ($redis.zincrby repo.storage_key(:tags), -1, collection[:tag].scoped_field).to_i <= 0
        $redis.zrem repo.storage_key(:tags), collection[:tag].scoped_field
      end
    end
      
    # Decrement TAG count in TAG collection
    if ($redis.zincrby "TAGS", -1, collection[:tag].scoped_field).to_i <= 0
      $redis.zrem "TAGS", collection[:tag].scoped_field
    end
    
    # REMOVE TAG from USER's tag collection relative to REPO
    # (this is kept in a dictionary to save memory)
    tag_array = user.tags_on_repo_as_array(repo)
    tag_array.delete(collection[:tag].scoped_field)
    $redis.hset user.storage_key(:repos, :tags), collection[:item].scoped_field, ActiveSupport::JSON.encode(tag_array)
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
  
  module ClassMethods
    
    def define_tag_strategy(opts={})
      opts[:namespace] ||= ""
      opts[:scope_by_field] ||= ""
      opts[:type] ||= ""
      
      self.tagging_system_type = opts[:type].to_s
      self.namespace = opts[:namespace].to_s
      self.scope_by_field = opts[:scope_by_field].to_s
    end
    
  end # ClassMethods
  
end