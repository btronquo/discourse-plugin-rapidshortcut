# frozen_string_literal: true

class CustomToolbarButtonsController < ApplicationController
  # ── Before actions ──────────────────────────────────────────────────────────
  before_action :ensure_logged_in, only: [:index]
  before_action :ensure_admin,     only: %i[admin_index create update destroy]
  before_action :plugin_enabled!
  before_action :find_button,      only: %i[update destroy]

  # ── Public endpoint ─────────────────────────────────────────────────────────
  # GET /custom-toolbar-buttons.json
  # Returns only the buttons the current user is authorised to see.
  def index
    buttons = CustomToolbarButton.for_user(current_user)
    render json: { buttons: serialize_data(buttons, CustomToolbarButtonSerializer) }
  end

  # ── Admin endpoints ─────────────────────────────────────────────────────────
  # GET /admin/plugins/custom-toolbar-buttons.json
  # Returns ALL buttons (enabled or not) for admin management.
  def admin_index
    buttons = CustomToolbarButton.order(:position, :created_at)
    render json: { buttons: serialize_data(buttons, CustomToolbarButtonSerializer) }
  end

  # POST /admin/plugins/custom-toolbar-buttons.json
  def create
    button = CustomToolbarButton.new(button_params)
    if button.save
      render json: serialize_data(button, CustomToolbarButtonSerializer)
    else
      render json: { errors: button.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /admin/plugins/custom-toolbar-buttons/:id.json
  def update
    if @button.update(button_params)
      render json: serialize_data(@button, CustomToolbarButtonSerializer)
    else
      render json: { errors: @button.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /admin/plugins/custom-toolbar-buttons/:id.json
  def destroy
    @button.destroy
    render json: success_json
  end

  private

  def plugin_enabled!
    raise Discourse::NotFound unless SiteSetting.custom_toolbar_buttons_enabled
  end

  def find_button
    @button = CustomToolbarButton.find_by(id: params[:id])
    raise Discourse::NotFound if @button.nil?
  end

  def button_params
    params.require(:custom_toolbar_button).permit(
      :title,
      :icon,
      :content,
      :permission,
      :position,
      :enabled
    )
  end
end
