class Cloud
  def self.render_cloud
    
    tag_cloud = []
    freqs = {word1: 2, word2: 5, word3: 3, word4: 1, word5: 1 }
    
    maxSize = 8 # max font size class
    minSize = 1 # min font size class
    
    # largest and smallest hash values
    maxQty = freqs.values.max
    minQty = freqs.values.min

    # find the range of values
    spread = maxQty - minQty
    spread = 1 if spread == 0 # we want to avoid divide by zero errors
    spread = 1 # testing
 
    # set the class_size increment
    step = maxSize - (minSize / spread)

    puts 'maxQty: ' + maxQty.to_s + ' minQty: ' + minQty.to_s + ' spread: ' + spread.to_s  + ' step: ' + step.to_s

    tag_cloud = []
    freqs.each do |word,score|
      class_size = minSize + ((score - minQty) * step)
      puts 'word: ' + word.to_s + ' score: ' + score.to_s + ' class_size: ' + class_size.to_s 
      tag_cloud.push('<font size="' + class_size.to_s + '">' + word.to_s + '::' + score.to_s + '</font>')
    end

    puts 'tag_cloud: ' + tag_cloud.to_s

  end
end