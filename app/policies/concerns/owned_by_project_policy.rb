# frozen_string_literal: true

# Shared ownership rule for records that belong (directly or indirectly) to a Project:
# only the owning user or an admin may view/modify them.
module OwnedByProjectPolicy
  def index?
    user.present?
  end

  def show?
    owner_or_admin?
  end

  def create?
    user.present?
  end

  def update?
    owner_or_admin?
  end

  def destroy?
    owner_or_admin?
  end

  private

  def owner_or_admin?
    user.present? && (owning_project.user_id == user.id || user.admin?)
  end

  def owning_project
    record.respond_to?(:project) ? record.project : record.project_floor.project
  end
end
