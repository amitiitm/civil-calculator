# frozen_string_literal: true

class DoorPolicy < ApplicationPolicy
  include OwnedByProjectPolicy

  class Scope < Scope
    def resolve
      return scope.none if user.nil?

      user.admin? ? scope.all : scope.joins(project_floor: :project).where(projects: { user_id: user.id })
    end
  end
end
