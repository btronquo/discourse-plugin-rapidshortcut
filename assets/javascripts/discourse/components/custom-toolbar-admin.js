import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

const EMPTY_FORM = {
  title: "",
  icon: "star",
  content: "",
  permission: "staff",
  position: 0,
  enabled: true,
};

export default class CustomToolbarAdmin extends Component {
  @service dialog;
  @service router;

  // ── State ──────────────────────────────────────────────────────────────────
  @tracked buttons = this.args.model || [];
  @tracked showForm = false;
  @tracked editingButton = null;
  @tracked isSaving = false;

  // ── Form fields ────────────────────────────────────────────────────────────
  @tracked formTitle = "";
  @tracked formIcon = "star";
  @tracked formContent = "";
  @tracked formPermission = "staff";
  @tracked formPosition = 0;
  @tracked formEnabled = true;

  // ── Static data ────────────────────────────────────────────────────────────
  PERMISSIONS = [
    { value: "everyone",      label: "Tout le monde" },
    { value: "trust_level_1", label: "Niveau de confiance 1+" },
    { value: "trust_level_2", label: "Niveau de confiance 2+" },
    { value: "trust_level_3", label: "Niveau de confiance 3+" },
    { value: "trust_level_4", label: "Niveau de confiance 4+" },
    { value: "staff",         label: "Staff (modérateurs + admins)" },
    { value: "moderator",     label: "Modérateurs uniquement" },
    { value: "admin",         label: "Admins uniquement" },
  ];

  // ── Computed ───────────────────────────────────────────────────────────────
  get iconPreviewValid() {
    return this.formIcon && this.formIcon.trim().length > 0;
  }

  // ── Actions — form open/close ──────────────────────────────────────────────
  @action
  openNewForm() {
    this.editingButton = null;
    this._loadForm(EMPTY_FORM);
    this.formPosition = this.buttons.length;
    this.showForm = true;
  }

  @action
  openEditForm(button) {
    this.editingButton = button;
    this._loadForm(button);
    this.showForm = true;
  }

  @action
  closeForm() {
    this.showForm = false;
    this.editingButton = null;
  }

  // ── Actions — form field updates ──────────────────────────────────────────
  @action
  updateField(field, event) {
    this[field] = event.target.value;
  }

  @action
  updateEnabled(event) {
    this.formEnabled = event.target.checked;
  }

  // ── Actions — CRUD ────────────────────────────────────────────────────────
  @action
  async saveButton() {
    if (!this.formTitle.trim() || !this.formContent.trim()) {
      this.dialog.alert("Le titre et le contenu sont obligatoires.");
      return;
    }

    this.isSaving = true;

    const payload = {
      custom_toolbar_button: {
        title:      this.formTitle.trim(),
        icon:       this.formIcon.trim() || "star",
        content:    this.formContent,
        permission: this.formPermission,
        position:   parseInt(this.formPosition, 10) || 0,
        enabled:    this.formEnabled,
      },
    };

    try {
      if (this.editingButton) {
        const updated = await ajax(
          `/admin/plugins/custom-toolbar-buttons/${this.editingButton.id}.json`,
          { method: "PUT", data: payload }
        );
        this.buttons = this.buttons.map((b) =>
          b.id === this.editingButton.id ? updated : b
        );
      } else {
        const created = await ajax(
          "/admin/plugins/custom-toolbar-buttons.json",
          { method: "POST", data: payload }
        );
        this.buttons = [...this.buttons, created];
      }

      this.closeForm();
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.isSaving = false;
    }
  }

  @action
  async toggleEnabled(button) {
    try {
      const updated = await ajax(
        `/admin/plugins/custom-toolbar-buttons/${button.id}.json`,
        {
          method: "PUT",
          data: {
            custom_toolbar_button: { enabled: !button.enabled },
          },
        }
      );
      this.buttons = this.buttons.map((b) =>
        b.id === button.id ? updated : b
      );
    } catch (e) {
      popupAjaxError(e);
    }
  }

  @action
  confirmDelete(button) {
    this.dialog.deleteConfirm({
      message: `Supprimer le bouton « ${button.title} » ? Cette action est irréversible.`,
      confirmButtonLabel: "Supprimer",
      didConfirm: async () => {
        try {
          await ajax(
            `/admin/plugins/custom-toolbar-buttons/${button.id}.json`,
            { method: "DELETE" }
          );
          this.buttons = this.buttons.filter((b) => b.id !== button.id);
        } catch (e) {
          popupAjaxError(e);
        }
      },
    });
  }

  // ── Private ────────────────────────────────────────────────────────────────
  _loadForm(src) {
    this.formTitle      = src.title      ?? "";
    this.formIcon       = src.icon       ?? "star";
    this.formContent    = src.content    ?? "";
    this.formPermission = src.permission ?? "staff";
    this.formPosition   = src.position   ?? 0;
    this.formEnabled    = src.enabled    ?? true;
  }
}
