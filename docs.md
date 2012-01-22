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













