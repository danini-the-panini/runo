module ApplicationHelper

  def inline_svg(name)
    File
      .read(Rails.root.join('app', 'assets', 'images', name))
      .gsub('#FF00FF', 'currentColor')
      .html_safe
  end

  def inline_card(card)
    inline_svg("cards/#{[card.face, card.plus.zero? ? nil : card.plus].compact.join('_')}.svg")
  end
  
end
