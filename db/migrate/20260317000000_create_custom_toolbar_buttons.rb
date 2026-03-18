# frozen_string_literal: true

class CreateCustomToolbarButtons < ActiveRecord::Migration[7.0]
  def change
    create_table :custom_toolbar_buttons do |t|
      # Human-readable label shown as tooltip on the button
      t.string  :title,      null: false

      # FontAwesome icon name (e.g. "star", "bolt", "info-circle")
      t.string  :icon,       null: false, default: "star"

      # The text that will be inserted in the composer when the button is clicked
      t.text    :content,    null: false

      # Who can see/use this button:
      #   everyone | trust_level_1 | trust_level_2 | trust_level_3 | trust_level_4
      #   staff    | moderator     | admin
      t.string  :permission, null: false, default: "staff"

      # Lower number = displayed first in the toolbar
      t.integer :position,   null: false, default: 0

      # Soft on/off switch without deleting the row
      t.boolean :enabled,    null: false, default: true

      t.timestamps
    end

    add_index :custom_toolbar_buttons, [:enabled, :position]
  end
end
