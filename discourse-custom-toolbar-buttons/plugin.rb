# frozen_string_literal: true

# name: discourse-rapidshortcut
# about: Allows admins to configure custom text-insertion buttons in the post composer toolbar, with per-permission-level access control
# version: 1.0.0
# authors: Boris Tronquoy
# url: https://github.com/btronquo/discourse-plugin-rapidshortcut

enabled_site_setting :rapidshortcut_buttons_enabled

# Register the admin route (appears in Admin > Plugins)
add_admin_route "rapidshortcut_buttons.admin.title", "custom-toolbar-buttons"

after_initialize do
  require_relative "app/models/rapidshortcut_button"
  require_relative "app/controllers/rapidshortcut_buttons_controller"
  require_relative "app/serializers/rapidshortcut_button_serializer"

  # ─── Routes ────────────────────────────────────────────────────────────────
  Discourse::Application.routes.append do
    # Public endpoint: returns buttons the current user is allowed to see
    get "/custom-toolbar-buttons" => "rapidshortcut_buttons#index"

    # Admin CRUD
    scope "/admin", constraints: AdminConstraint.new do
      get    "plugins/custom-toolbar-buttons"      => "rapidshortcut_buttons#admin_index"
      post   "plugins/custom-toolbar-buttons"      => "rapidshortcut_buttons#create"
      put    "plugins/custom-toolbar-buttons/:id"  => "rapidshortcut_buttons#update"
      patch  "plugins/custom-toolbar-buttons/:id"  => "rapidshortcut_buttons#update"
      delete "plugins/custom-toolbar-buttons/:id"  => "rapidshortcut_buttons#destroy"
    end
  end

  # ─── Inject buttons into the current_user serializer (synchronous page load) ─
  add_to_serializer(:current_user, :rapidshortcut_buttons) do
    return [] unless SiteSetting.rapidshortcut_buttons_enabled

    CustomToolbarButton.for_user(object).map do |b|
      { id: b.id, title: b.title, icon: b.icon, content: b.content }
    end
  end
end
