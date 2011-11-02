module TagHelper

  def link_to_tag(tag, path)
    (link_to "#{tag.relative_count}-#{tag.name}", path, :class => "tag", :title => tag.name).html_safe
  end
    
  def output_tag_links(tags, inline=false)
    html = "<ul class=\"tag_box\" #{("inline" if inline)}>"
    Array(tags).each do |tag|
      html += "<li>" + (link_to "#{tag.relative_count}-#{tag.name}", repos_tagged_path(tag.name), :class => "tag", :title => tag.name) + "</li>"
    end
    html += "</ul>"

    html.html_safe
  end
  
  # tags come in the format: 
  # ["ruby", "1", "git", "1"] 
  def output_tags(tags, base_url)
    html = ""
		tags.each_with_index do |tag, i|
			if !i.zero?
				next unless i.even?
			end
		  
		  html += (link_to "#{tags[i+1]}-#{tag}", "#{base_url}?tags=#{tag}")
    end

  	html.html_safe
  end

  # tags come in the format: 
  # ["ruby", "1", "git", "1"]
  
  def to_tag_string(tags)
		tags.each_with_index.map { |tag, i|
			next if (i > 0 && i.odd?)
		  tag
    }.join(":").html_safe
  end
  
  def format_tags(tags)
    tags.map!{ |tag| "<span>#{tag.name}</span>" }.join(" + ").html_safe
  end
  
end
