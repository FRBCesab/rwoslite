#' 
#' Create an Hexagonal Sticker for the Package
#' 

hexSticker::sticker(
  
  subplot  = here::here("inst", "logo", "clarivate.png"),
  package  = "rwoslite",
  filename = here::here("man", "figures", "hexsticker.png"),
  dpi      = 1200,
  
  p_size   = 72.0,        # Title
  u_size   = 12.0,        # URL
  p_family = "Aller_Rg",
  
  p_color  = "#040404",   # Title
  h_fill   = "#56590D",   # Background
  h_color  = "#89775F",   # Border
  u_color  = "#040404",   # URL
  
  p_x      = 1.00,        # Title
  p_y      = 0.60,        # Title
  
  s_x      = 1.00,        # Subplot
  s_y      = 1.25,        # Subplot
  s_width  = 0.5,
  s_height = 2.5,
  
  spotlight = TRUE,
  
  l_alpha   = 0.20,
  l_width   = 3,
  l_height  = 3,
  
  asp = 0.90,
  
  url      = "https://frbcesab.github.io/rwoslite"
)
