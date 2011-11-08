http://library.linode.com/databases/redis/ubuntu-10.04-lucid

create persistance strategy for redis.
	Firstly I have to implement the append only and save every second stuff.
	then do the cron jobs to maintain a lean AOF file
	then have a way to export those database snapshots.
	would be nice to test spawning new redis server from snapshot

	need ruby code to ping server and try to restart it on fail
	need pinging software to alert me when there's downtime
	
## api

### User instance

    @user.buddy_get(:users)  # invalid
    @user.buddy_get(:items)  # get all items tagged by @user
    @user.buddy_get(:tags)   # get all tags used by @user

    @user.buddy_get(:users, :via => @tags)  # invalid
    @user.buddy_get(:items, :via => @tags)  # get all items tagged by @user with @tags
    @user.buddy_get(:tags, :via => @item)   # get all tags made by @user on @item

### Item instance
		
    @item.buddy_get(:users)  # all users that have tagged this item.
    @item.buddy_get(:items)  # invalid
    @item.buddy_get(:tags)   # all tags on this item.

    @item.buddy_get(:users, :via => @tags)  # all users that have tagged this item with @tags.
    @item.buddy_get(:items, :via => @tags)  # invalid
    @item.buddy_get(:tags, :via => @user)   # all tags on @item by @user

### Tag instance

    @tag.buddy_get(:users)  # all users that have used @tag.
    @tag.buddy_get(:items)  # all items tagged by @tag
    @tag.buddy_get(:tags)   # invalid

    @tag.buddy_get(:users, :via => @item)   # all users that have tagged @item with @tag
    @tag.buddy_get(:items, :via => @user)   # all items tagged @tag by @user
    @tag.buddy_get(:tags, :via => @user)    # invalid

## Redis Data Model

		TAGS = [1:"mysql", 3:"ruby"] 
					 	Type: Sorted set
					 	Desc: All tags and their total counts from repos.
						ex:   TAGS
    TAG
			:{"mysql"}

				:users = [1,2]
								 	Type: Array
				  			 	Desc: All users that are using the tag "mysql"
									ex:   TAG:mysql:users
				:items = [1,2]  
									Type: Array
									Desc: All items tagged "mysql"
									ex:   TAG:mysql:items

		USER
			:{"1"}

				:tags = [1:"mysql", 3:"ruby"] 
								 Type: Sorted Set
								 Desc: all tags used by this user and the # of repos tagged related to this user.
								 ex:   USER:1:tags

				:items = [1,2] 
									Type: Array
									Desc: All repos tagged by this user
									ex:   USER:1:items

					:tags = { :ghid => ["mysql", "ruby"] # as json }
									  Type: Hash
										Desc: A dictionary of all tags per repo
										ex:   USER:1:items:tags
				:tag
					:{"mysql"}
					 	:items = [1,2] 
											Type: Array
											Desc: repos tagged with this tag by this user.
											ex:   USER:1:tag:mysql:items

		ITEM
			:{"1"}

				:tags = [1:"mysql", 3:"ruby"] 
									Type: Sorted Set
									Desc: All tags on this repo (by users) and total count
									ex:   ITEM:1:tags

				:users = [1,2] 
									Type: Array
									Desc: All users that have tagged this repo.
									ex:   ITEM:1:users