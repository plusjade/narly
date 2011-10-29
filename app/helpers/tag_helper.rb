module TagHelper
  
  
  # tags come in the format: 
  # ["ruby", "1", "git", "1"] 
  def output_tags(tags)
    html = ""
		tags.each_with_index do |tag, i|
			if !i.zero?
				next unless i.even?
			end
		  
		  html += (link_to "#{tag} - #{tags[i+1]}", "#")
    end

  	html.html_safe
  end

end
