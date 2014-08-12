module Styles

  STYLES = {
    # foreground text
    :black_fg   => 30,
    :red_fg     => 31,
    :green_fg   => 32,
    :yellow_fg  => 33,
    :blue_fg    => 34,
    :magenta_fg => 35,
    :cyan_fg    => 36,
    :white_fg   => 37,

    # background
    :black_bg   => 40,
    :red_bg     => 41,
    :green_bg   => 42,
    :yellow_bg  => 43,
    :blue_bg    => 44,
    :magenta_bg => 45,
    :cyan_bg    => 46,
    :white_bg   => 47,

    # text styles
    :bold => 1
  }

  def styled_text(text, *styles)
    create_style(*styles) + text + if block_given? then yield else end_style end
  end

  def create_style(*styles)
    "\e[#{STYLES.values_at(*styles).join(';')}m"
  end

  def end_style
    "\e[0m"
  end

end