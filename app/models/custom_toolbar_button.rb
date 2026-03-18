# frozen_string_literal: true

class CustomToolbarButton < ActiveRecord::Base
  # ── Permission levels ───────────────────────────────────────────────────────
  PERMISSIONS = %w[
    everyone
    trust_level_1
    trust_level_2
    trust_level_3
    trust_level_4
    staff
    moderator
    admin
  ].freeze

  PERMISSION_LABELS = {
    "everyone"      => "Tout le monde",
    "trust_level_1" => "Niveau de confiance 1+",
    "trust_level_2" => "Niveau de confiance 2+",
    "trust_level_3" => "Niveau de confiance 3+",
    "trust_level_4" => "Niveau de confiance 4+",
    "staff"         => "Staff (modérateurs + admins)",
    "moderator"     => "Modérateurs",
    "admin"         => "Admins uniquement",
  }.freeze

  # ── Validations ─────────────────────────────────────────────────────────────
  validates :title,      presence: true, length: { maximum: 100 }
  validates :icon,       presence: true, length: { maximum: 60 }
  validates :content,    presence: true
  validates :permission, inclusion: { in: PERMISSIONS }
  validates :position,   numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :enabled,    inclusion: { in: [true, false] }

  # ── Scopes ──────────────────────────────────────────────────────────────────
  scope :active, -> { where(enabled: true).order(:position, :created_at) }

  # ── Class methods ───────────────────────────────────────────────────────────

  # Returns the subset of enabled buttons the given user is authorised to use.
  def self.for_user(user)
    return [] if user.nil?

    active.select { |button| button.visible_to?(user) }
  end

  # ── Instance methods ────────────────────────────────────────────────────────

  def visible_to?(user)
    return false if user.nil?

    case permission
    when "everyone"      then true
    when "trust_level_1" then user.trust_level >= 1
    when "trust_level_2" then user.trust_level >= 2
    when "trust_level_3" then user.trust_level >= 3
    when "trust_level_4" then user.trust_level >= 4
    when "staff"         then user.staff?
    when "moderator"     then user.moderator? || user.admin?
    when "admin"         then user.admin?
    else false
    end
  end
end
