
## Core feature outline

- the user should be able to add tags to his repos.
- the user should be able to filter his repos by these tags.
- the user should be able to filter by a combination of tags.
- the user should be able to see all tags for a given repo.
- the user should be able to see other repos tagged by the same tag or combination of tags.
- the user should be able to see another user's tags.
- the user should be able to explore trending/popular (quality) repos based on tags or a set of tags
- the user should be able to see/use the most popular tags.

## 3 kinds of objects right now.


- TAG 
- USER 
- REPO



    TAG
			:{"mysql"}
				:users = [1,2]  # users that are using the tag "mysql"
				:repos = [1,2]  # repos tagged "mysql"
		
		USER
			:{"1"}
				:tags = [1:"mysql", 3:"ruby"] # tags used by this user and the # of repos tagged related to this user.
				:repos = [1,2] # repos watched/owned by this user
		
		REPO
			:{"1"}
				:tags = [1:"mysql", 3:"ruby"] # tags on this repo (by users) and total count
				:users = [1,2] # users that have tagged this repo.
			
			
Usage:

plusjade:uid tags:"mysql" on repo:112 



Tag:mysql:users add plusjade.uid
Tag:mysql:repos add 112

User:uid:tags add +1:"mysql"
User:uid:repos add 112

Repo:112:tags  +1:"mysql"
Repo:112:users add uid



			