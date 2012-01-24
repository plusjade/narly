Hi all, I'm currently working on major updates in the [framework-beta branch](https://github.com/plusjade/jekyll-bootstrap/commits/framework-beta)
I haven't started on upgrading the documentation so I recommend reading the commit messages to get a handle for what I've been up to.

I'd like anyone interested (@swanson) to provide feedback on the updates. Mainly if you agree/disagree and of course design recommendations/suggestions. 

## Main Additions

### All Jekyll bootstrap include helpers are now name-spaced into `_includes/JB`

Additionally the "helpers" have been flattened out into the JB directory. This improves the simplicity of the API. i.e. Calling a helper is a much shorter syntax:
 
````
{% include JB/comments %} 
...
{% assign pages_list = site.pages %} {% include JB/pages_list %}
````

### All JB helpers can be overridden 

I've added the ability to define custom versions of all helpers so users don't need to edit the JB source. This is very important for versioning and upgrading. The current API is to set a helper "engine" to _custom_ then create a file having the same name as the helper in `_includes/custom/`

### Comments and analytics integration

Finally got around to adding integration for the most common commenting and analytics engines.

### Support for dynamic paths.

I've elected to dynamically define the liquid variables: `BASE_PATH` and `ASSET_PATH`.
The framework now expects all links to be prepended with `BASE_PATH`.

**Benefits**

This feature enables GitHub "project" pages to be supported (just assign BASE\_PATH to the project name).

Regardless of the settings,  localhost will always run from root "/". 
When you push to GitHub, JB reads the site.safe flag and sets `BASE_PATH` for "production mode".

Using `site.baseurl` achieves similar subdirectory support but I really do not like having to
remember to go to http://localhost:4000/repo-name

**Drawbacks**

All pages/post have to include JB/setup in order to use the variables. (this is automatically done when using the rake tasks)

### New rake tasks for page and post creation

@pradeep1288 kindly added a `rake new_post` task to which I added another for creating a page.
I've renamed both to just `rake post` and `rake page` so as to be a "faster" way to publish.
Additionally I've switched to passing ENV variables over rake arguments.



# What's new

All Jekyll-Bootstrap code should be namespaced with JB

## Theme API


### Comments

    {% include JB/comments %}

### Analytics

    {% include JB/analytics %}
    
### Sharing
    
    {% include JB/sharing %}
    

## Configuration 
   
    
### Global configuration : \_config.yml
  
Namespaced Jekyll-Bootstrap config via `JB` hash

### Theme Specific configuration 

`./_includes/theme/THEME-NAME/settings.yml`

YAML in this file will be injected into the root `default.html` layout
which means all data is available through : `page.theme`

Jekyll-Bootstrap highly recommends the convention of name-spacing your data
with "theme". So your settings file should always build a hash with key `theme`

    theme :
      footer_links :
        - /blah.html
        - /yo.html
        - /hi.html













