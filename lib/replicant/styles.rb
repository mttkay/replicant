module Styles

  STYLES = {
    # foreground text
    :white_fg => 37,
    :black_fg => 30,
    :green_fg => 32,

    # background
    :white_bg => 47,

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