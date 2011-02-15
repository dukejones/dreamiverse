class Cloud
  def self.render_cloud
    
    tag_cloud = []
    # some test freqs

    freqs = { 544=>11, 538=>8, 517=>6, 524=>4, 548=>32, 592=>1 }
    freqs = { 544=>11, 538=>10, 517=>10, 524=>9, 548=>9, 592=>9, 516=>8, 551=>7, 537=>7, 566=>7, 549=>6, 523=>6, 589=>6, 581=>6, 564=>5, 547=>5 }
    
    maxSize = 16 # max font size class
    minSize = 1 # min font size class
    
    # largest and smallest hash values
    maxQty = freqs.values.max
    minQty = freqs.values.min

    # find the range of values
    spread = maxQty - minQty
    spread = 1 if spread == 0 # we want to avoid divide by zero errors
    #spread = 1 # testing
 
    #step = 0.to_f
    # set the class_size increment
    step = (maxSize.to_f - minSize.to_f)
    step = step / spread.to_f
    
    #step = 7.0 / 10.0
    #step.to_f
    #step = 0.7
    
    #step = 1 #testing

    puts 'maxSize: ' + maxSize.to_s + ' minSize: ' + minSize.to_s + ' maxQty: ' + maxQty.to_s + ' minQty: ' + minQty.to_s + ' spread: ' + spread.to_s#  + ' step: ' + step.to_f

    tag_cloud = []
    freqs.each do |what_id,score|
      what = What.find(what_id)
      class_size = minSize + ((score - minQty) * step).to_i
      puts 'what_id: ' + what_id.to_s + ' name: ' + what.name +  ' score: ' + score.to_s + ' class_size: ' + class_size.to_s  
      #div class=\"TC s-$size water\">
      tag_cloud.push('<div class="TC s-' + class_size.to_s + ' water">' + what.name.to_s + '</font>')
    end

    puts 'tag_cloud: ' + tag_cloud.to_s
    #tag_cloud.shuffle
    return tag_cloud
  end
end