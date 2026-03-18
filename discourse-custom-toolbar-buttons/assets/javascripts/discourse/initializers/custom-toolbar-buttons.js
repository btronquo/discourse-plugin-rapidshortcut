import { withPluginApi } from "discourse/lib/plugin-api";

/**
 * discourse-custom-toolbar-buttons — composer toolbar integration
 *
 * Buttons are pre-loaded into `currentUser.custom_toolbar_buttons` by the
 * Ruby serializer extension in plugin.rb, so there is NO async AJAX call here.
 * This guarantees buttons are registered before the first toolbar render.
 */
export default {
  name: "custom-toolbar-buttons",

  initialize() {
    withPluginApi("0.8.31", (api) => {
      if (!api.getSiteSettings().custom_toolbar_buttons_enabled) return;

      const currentUser = api.getCurrentUser();
      if (!currentUser) return;

      const customButtons = currentUser.custom_toolbar_buttons || [];
      if (!customButtons.length) return;

      api.onToolbarCreate((toolbar) => {
        customButtons.forEach((button) => {
          toolbar.addButton({
            // Unique DOM id for the button
            id: `ctb-${button.id}`,

            // Placed in the "extras" group at the right side of the toolbar
            // (same group as the Upload and emoji buttons)
            group: "extras",

            icon: button.icon,

            // Shown as tooltip on hover
            title: button.title,

            // Called when the user clicks the button
            action: (toolbarEvent) => {
              toolbarEvent.addText(button.content);
            },
          });
        });
      });
    });
  },
};
