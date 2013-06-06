module Front::FrontHelper
  def menu_class(actual_menu_name)
    menus = {
      :chair_support => ["/front/pages/chair_support"],
      :cinecitarios => ["/front/pages/cinecitarios"]
    }

    path = request.fullpath.gsub(/\?.*/, "")

    return "active" if menus[actual_menu_name].to_a.any? { |e| path =~ /^#{e}$/ }
    return "no-active"
  end
end
