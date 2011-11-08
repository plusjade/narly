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
