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

  def span(text, *styles)
    styled = "\e[#{STYLES.values_at(*styles).join(';')}m#{text}"
    styled << yield if block_given?
    styled
  end

  def styled(*styles)
    "\e[#{STYLES.values_at(*styles).join(';')}m"
  end

  def unstyled
    "\e[0m"
  end

end