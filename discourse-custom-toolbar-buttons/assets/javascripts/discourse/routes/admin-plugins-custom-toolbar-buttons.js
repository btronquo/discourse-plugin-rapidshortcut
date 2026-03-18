import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

/**
 * Route for Admin > Plugins > Custom Toolbar Buttons
 * Fetches all buttons (including disabled ones) for admin management.
 */
export default class AdminPluginsCustomToolbarButtonsRoute extends DiscourseRoute {
  async model() {
    const data = await ajax("/admin/plugins/custom-toolbar-buttons.json");
    return data.buttons || [];
  }
}
