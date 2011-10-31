module TagSystem

  # Record everything needed to make user<->rep tag associations.
  # We use redis to store associations and counts relative to those associations.
  #
  # Notes:
  #   $redis.sadd returns bool for singular value additions.
  #   Bool value reflects whether the insertion was newly added.
  #
  def make_tag_associations(user, repo, tag)
    user = (user.is_a? User)       ? user : User.first(:ghid => user.to_i)
    repo = (repo.is_a? Repository) ? repo : Repository.new(:ghid => repo.to_i)
    tag  = (tag.is_a? Tag)         ? tag  : Tag.new(tag)

    # Add REPO to the USER'S total REPO collection relative to TAG
    is_new_tag_on_repo_for_user = ($redis.sadd user.redis_key_for_tag_repos(tag.name), repo.ghid)

    $redis.multi do
      # Add REPO to the USERS's total REPO collection.
      $redis.sadd user.redis_key(:repos), repo.ghid

      # Add USER to the REPO's total USER collection
      $redis.sadd repo.redis_key(:users), user.ghid
      
      # Add USER to the TAG's total USER collection.
      $redis.sadd tag.redis_key(:users), user.ghid

      # Add REPO to the TAG's total REPO collection.
      $redis.sadd tag.redis_key(:repo), repo.ghid
      
      if is_new_tag_on_repo_for_user
        # Increment the USER's TAG count for TAG
        $redis.zincrby user.redis_key(:tags), 1, tag.name
        
        # Increment the REPO's TAG count for TAG
        $redis.zincrby repo.redis_key(:tags), 1, tag.name
      end
    end
      
  end
  
end