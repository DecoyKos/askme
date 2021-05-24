module ApplicationHelper
  def user_avatar(user)
    if user.avatar_url.present?
      user.avatar_url
    else
      asset_path 'avatar.png'
    end
  end

  def declination(number, enot, enota, enotov)
    modulo = number % 10
    return enotov if (11..14).include?(number % 100)
    return enot if modulo == 1
    return enota if (2..4).include?(modulo)
    return enotov if (5..9).include?(modulo)
    return enotov
  end
end
