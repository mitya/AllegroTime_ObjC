# #!/usr/bin/env ruby

$images = "data/images"
$sources = "artefacts/images"

task :cellbg do
  colors = {
    red: "#f00-#c00",
    green: "#0a0-#080",
    yellow: "#ff0-#dd0",
  }
  
  basename = "cell-bg"
  height = 45
  
  colors.each_pair do |name, color|
    `convert -size 1x#{height} gradient:#{color} #{$images}/#{basename}-#{name}.png`
    `convert -size 1x#{height*2} gradient:#{color} #{$images}/#{basename}-#{name}@2x.png`
  end  
end

task :pins do
  basename = "crossing-pin"
  # `cp ~/desktop/marker.001.png artefacts/images/#{basename}-red.png`
  # `cp ~/desktop/marker.002.png artefacts/images/#{basename}-yellow.png`
  # `cp ~/desktop/marker.003.png artefacts/images/#{basename}-green.png`
  
  colors = %w(red green yellow)
  colors.each do |color|
    source = "#{$sources}/#{basename}-#{color}.png"
    `convert #{source} -fuzz 15% -transparent "rgb(213, 250, 128)" #{source}`
    `convert #{source} -background transparent -gravity north -extent 200x400 #{source}`
    `convert #{source} -resize 30x60 #{$images}/#{basename}-#{color}.png`
    `convert #{source} -resize 60x120 #{$images}/#{basename}-#{color}@2x.png`
  end 
end

task :stripes do
  gradients = {
    red: %w(f00 e00),
    green: %w(0c0 0b0),
    yellow: %w(ff0 ee0),  
  }
  gradients.each_pair do |color_name, color_string| 
    `convert -size 15x44 xc:transparent -fill radial-gradient:##{color_string.first}-##{color_string.last} -draw 'rectangle 8,0 15,44' data/images/cell-stripe-#{color_name}.png`
    `convert -size 30x88 xc:transparent -fill radial-gradient:##{color_string.first}-##{color_string.last} -draw 'rectangle 16,0 30,88' data/images/cell-stripe-#{color_name}@2x.png`

    # `convert -size 6x44 xc:transparent -fill gradient:##{color_string.last}-##{color_string.first} -draw 'roundRectangle 0,5 5,38 1,1' data/images/cell-gradient-#{color_name}.png`
    # `convert -size 30x44 xc:transparent -fill gradient:##{color_string.last}-##{color_string.first} -draw 'circle 15,22 2,22' data/images/cell-gradient-#{color_name}.png`
    # `convert -size 20x44 radial-gradient:##{color_string.last}-##{color_string.first} data/images/cell-gradient-#{color_name}.png`
    # `convert -size 6x44 radial-gradient:##{color_string.first}-##{color_string.last} data/images/cell-gradient-#{color_name}.png`    
  end
end
