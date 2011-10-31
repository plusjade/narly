module TagHelper
  
  
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
