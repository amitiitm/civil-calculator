# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
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

  class Scope < Scope
    def resolve
      return scope.none if user.nil?

      user.admin? ? scope.all : scope.where(user: user)
    end
  end

  private

  def owner_or_admin?
    user.present? && (record.user_id == user.id || user.admin?)
  end
end
