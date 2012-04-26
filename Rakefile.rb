# #!/usr/bin/env ruby
# 
# colors = {
#   Red: "#f00-#c00",
#   Green: "#0a0-#080",
#   Yellow: "#ff0-#dd0",
# }
# 
# basename = "TableViewCell"
# height = 45
# 
# colors.each_pair do |name, color|
#   `convert -size 1x#{height} gradient:#{color} #{basename}-#{name}Gradient.png`
#   `convert -size 1x#{height*2} gradient:#{color} #{basename}-#{name}Gradient@2x.png`
# end

colors = %w(red green yellow)

task :make_markers do
  `cp ~/desktop/marker.001.png artefacts/images/pin-red.v4.png`
  `cp ~/desktop/marker.002.png artefacts/images/pin-yellow.v4.png`
  `cp ~/desktop/marker.003.png artefacts/images/pin-green.v4.png`
  
  colors.each do |color|
    source = "artefacts/images/pin-#{color}.v4.png"
    `convert #{source} -fuzz 15% -transparent "rgb(213, 250, 128)" #{source}`
    `convert #{source} -background transparent -gravity north -extent 200x400 #{source}`
    `convert #{source} -resize 40x80 data/images/pin.v4-#{color}.png`
    `convert #{source} -resize 80x160 data/images/pin.v4-#{color}@2x.png`
  end 
end

gradients = {
  red: %w(f00 e00 d00 c00),
  green: %w(0f0 0e0 0d0 0c0),
  yellow: %w(ff0 ee0 dd0 cc0),  
}

task :make_gradients do
  gradients.each_pair do |color_name, color_string| 
    `convert -size 15x44 xc:transparent -fill radial-gradient:##{color_string.first}-##{color_string[1]} -draw 'rectangle 8,0 15,44' data/images/cell-stripe-#{color_name}.png`


    # `convert -size 6x44 xc:transparent -fill gradient:##{color_string.last}-##{color_string.first} -draw 'roundRectangle 0,5 5,38 1,1' data/images/cell-gradient-#{color_name}.png`
    # `convert -size 30x44 xc:transparent -fill gradient:##{color_string.last}-##{color_string.first} -draw 'circle 15,22 2,22' data/images/cell-gradient-#{color_name}.png`
    # `convert -size 20x44 radial-gradient:##{color_string.last}-##{color_string.first} data/images/cell-gradient-#{color_name}.png`
    # `convert -size 6x44 radial-gradient:##{color_string.first}-##{color_string.last} data/images/cell-gradient-#{color_name}.png`    
  end
end
