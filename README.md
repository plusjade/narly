
## Core feature outline

- the user should be able to add tags to his repos.
- the user should be able to filter his repos by these tags.
- the user should be able to filter by a combination of tags.
- the user should be able to see all tags for a given repo.
- the user should be able to see other repos tagged by the same tag or combination of tags.
- the user should be able to see another user's tags.
- the user should be able to explore trending/popular (quality) repos based on tags or a set of tags
- the user should be able to see/use the most popular tags.

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
				:repos = [1,2]  
									Type: Array
									Desc: All repos tagged "mysql"
									ex:   TAG:mysql:users:repos
		
		USER
			:{"1"}

				:tags = [1:"mysql", 3:"ruby"] 
								 Type: Sorted Set
								 Desc: all tags used by this user and the # of repos tagged related to this user.
								 ex:   USER:1:tags

				:repos = [1,2] 
									Type: Array
									Desc: All repos tagged by this user
									ex:   USER:1:repos

					:tags = { :ghid => ["mysql", "ruby"] # as json }
									  Type: Hash
										Desc: A dictionary of all tags per repo
										ex:   USER:1:repos:tags
				:tag
					:{"mysql"}
					 	:repos = [1,2] 
											Type: Array
											Desc: repos tagged with this tag by this user.
											ex:   USER:1:tag:mysql:repos
		
		REPO
			:{"1"}
			
				:tags = [1:"mysql", 3:"ruby"] 
									Type: Sorted Set
									Desc: All tags on this repo (by users) and total count
									ex:   REPO:1:tags
									
				:users = [1,2] 
									Type: Array
									Desc: All users that have tagged this repo.
									ex:   REPO:1:users
			
			
## Usage

plusjade:uid tags:"mysql" on repo:112 



Tag:mysql:users add plusjade.uid
Tag:mysql:repos add 112

User:uid:tags add +1:"mysql"
User:uid:repos add 112

Repo:112:tags  +1:"mysql"
Repo:112:users add uid



			